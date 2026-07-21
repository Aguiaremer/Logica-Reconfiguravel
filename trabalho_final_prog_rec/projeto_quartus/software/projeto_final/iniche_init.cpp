extern "C" {
#include "alt_error_handler.h"
#include "includes.h"
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "simple_socket_server.h"
#include "tcpport.h"
#include <altera_msgdma.h>          // mSGDMA core engine API
#include <altera_msgdma_csr_regs.h> // Bitmask headers for descriptors/status
#include <io.h>
#include <io.h>    // Safe I/O macros (IOWR_16DIRECT, etc.)
#include <nios2.h> // Core Nios II architecture hooks
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/alt_cache.h>
#include <sys/alt_cache.h> // Cache invalidation & flushing primitives
#include <system.h>        // System-wide peripheral definitions
}
#define USER_HW_COEFF_BASE USERHW_0_BASE

#define FILTER_TAPS 16
#define PACKET_SAMPLES 32

int16_t tx_buffer[PACKET_SAMPLES] __attribute__((aligned(32)));
int16_t rx_buffer[PACKET_SAMPLES] __attribute__((aligned(32)));

OS_STK SSSInitialTaskStk[TASK_STACKSIZE * 2];

#define TASK_STACK_SIZE 1024
#define RX_TASK_PRIO 11
#define TX_TASK_PRIO 12
#define PROCESS_TASK_PRIO 13

OS_STK RX_Task_Stk[TASK_STACK_SIZE];
OS_STK TX_Task_Stk[TASK_STACK_SIZE];
OS_STK Process_Task_Stk[TASK_STACK_SIZE];

OS_EVENT *Disconnect_Sem;

int Active_Socket = -1;

OS_EVENT *Wake_RX_Sem;
OS_EVENT *Wake_TX_Sem;

#define QUEUE_BUFF_SIZE 10

void *RXtoProcessBuffer[QUEUE_BUFF_SIZE];
void *ProcesstoTXBuffer[QUEUE_BUFF_SIZE];

OS_EVENT *RX_to_Process_Queue;
OS_EVENT *Process_to_TX_Queue;

#define MAX_SAMPLES_PER_PACKET 256

typedef enum {
  MSG_TYPE_INIT_REQ = 0x01,
  MSG_TYPE_INIT_ACK = 0x02,
  MSG_TYPE_AUDIO_REQ = 0x03,
  MSG_TYPE_AUDIO_RES = 0x04,
  MSG_TYPE_ERROR = 0xFF
} MessageType;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint8_t is_eof;

  uint16_t num_samples;
  uint32_t sequence_num;

  int16_t samples[MAX_SAMPLES_PER_PACKET];
} AudioDataRequest;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint8_t status_code;
  uint16_t num_samples;
  uint32_t sequence_num;

  int16_t filtered_samples[MAX_SAMPLES_PER_PACKET];
} AudioDataResponse;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint16_t num_taps;
  int16_t coefficients[FILTER_TAPS];
} FilterConfigRequest;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint8_t status_code;
} FilterConfigResponse;

void write_coefficient(uint8_t index, int16_t value) {
  if (index >= FILTER_TAPS)
    return;

  int16_t *uncached_base = (int16_t *)(USER_HW_COEFF_BASE | 0x80000000);
  *(uncached_base + index) = (int16_t)value;
}

int16_t read_coefficient(uint8_t index) {
  if (index >= FILTER_TAPS)
    return 0;

  int16_t *uncached_base = (int16_t *)(USER_HW_COEFF_BASE | 0x80000000);
  return *(uncached_base + index);
}

void write_fir_input(int16_t value) {
  *((volatile int16_t *)(FIFO_TX_IN_BASE | 0x80000000)) = value;
}

int16_t read_fir_output() {
  return *((volatile int16_t *)(FIFO_RX_OUT_BASE | 0x80000000));
}

void clear_fir() {
  for (int i = 0; i < FILTER_TAPS; ++i) {
    write_fir_input(0);
  }
  for (int i = 0; i < FILTER_TAPS; ++i) {
    (void)read_fir_output();
  }
}

// --- Task 2: RX ---
void RX_Task(void *pdata) {
  INT8U err;
  AudioDataRequest *rx_buf;

  while (1) {
    OSSemPend(Wake_RX_Sem, 0, &err);

    while (Active_Socket != -1) {
      rx_buf = new AudioDataRequest();
      int len = recv(Active_Socket, (char *)rx_buf, sizeof(*rx_buf), 0);

      if (len > 0) {
        OSQPost(RX_to_Process_Queue, (void *)rx_buf);
      } else {
        // Connection closed by client or error
        delete rx_buf;
        OSSemPost(Disconnect_Sem);
        break;
      }
    }
  }
}

// --- Task 3: Processing ---
void Processing_Task(void *pdata) {
  INT8U err;
  AudioDataRequest *data_in;
  AudioDataResponse *data_out;
  volatile uint32_t *user_hw =
      (volatile uint32_t *)(USERHW_0_BASE | 0x80000000);

  while (1) {
    // Blocks automatically. If no connection, queue is just empty.
    data_in = (AudioDataRequest *)OSQPend(RX_to_Process_Queue, 0, &err);

    data_out = new AudioDataResponse();
    data_out->num_samples = data_in->num_samples;
    data_out->status_code = EXIT_SUCCESS;
    data_out->msg_type = MSG_TYPE_AUDIO_RES;

    for (int i = 0; i < data_in->num_samples; i++) {
      write_fir_input(data_in->samples[i]);
      data_out->filtered_samples[i] = read_fir_output();
    }

    OSQPost(Process_to_TX_Queue, (void *)data_out);

    uint8_t eof = data_in->is_eof;
    delete data_in;
    if (eof) {
      continue;
    }
  }
}

// --- Task 4: TX ---
void TX_Task(void *pdata) {
  INT8U err;
  AudioDataResponse *data_to_send;

  while (1) {
    // Wait for connection to be active
    OSSemPend(Wake_TX_Sem, 0, &err);

    while (Active_Socket != -1) {
      // Block until data is ready to send.
      // Include a timeout here so we can check if Active_Socket closed!
      data_to_send = (AudioDataResponse *)OSQPend(Process_to_TX_Queue, 100,
                                                  &err); // 100 tick timeout

      if (err == OS_NO_ERR) {
        send(Active_Socket, (char *)data_to_send, sizeof(*data_to_send), 0);
        delete data_to_send;
      }
      // If it timed out, loop repeats, checks Active_Socket condition.
      // If connection dropped, Active_Socket will be -1, loop breaks.
    }
  }
}

void SSSInitialTask(void *task_data) {

  INT8U error_code;
  alt_iniche_init();
  netmain();
  while (!iniche_net_ready)
    TK_SLEEP(1);
  printf("\nSimple Socket Server starting up\n");

  struct sockaddr_in addr, remote;
  int fd_listen, len = sizeof(remote);

  if ((fd_listen = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,
                            (char *)"[sss_task] Socket creation failed");
  }

  addr.sin_family = AF_INET;
  addr.sin_port = htons(SSS_PORT);
  addr.sin_addr.s_addr = INADDR_ANY;

  if ((bind(fd_listen, (struct sockaddr *)&addr, sizeof(addr))) < 0) {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,
                            (char *)"[sss_task] Bind failed");
  }

  if ((listen(fd_listen, 1)) < 0) {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,
                            (char *)"[sss_task] Listen failed");
  }
  printf("[sss_task] Simple Socket Server listening on port %d\n", SSS_PORT);

  while (1) {
    if ((Active_Socket = accept(fd_listen, (struct sockaddr *)&remote, &len)) <
        0) {
      alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,
                              (char *)"[sss_handle_accept] accept failed");
    }
    printf("[sss_task] Simple Socket Server accepted client %d\n", SSS_PORT);

    FilterConfigRequest request;

    int len = recv(Active_Socket, (char *)&request, sizeof(request), 0);

    if (request.msg_type == MSG_TYPE_INIT_REQ) {
      for (int i = 0; i < FILTER_TAPS; ++i) {
        write_coefficient(i, request.coefficients[i]);
      }
      FilterConfigResponse response;
      response.msg_type = MSG_TYPE_INIT_ACK;
      response.status_code = EXIT_SUCCESS;
      send(Active_Socket, (char *)&response, sizeof(response), 0);
    } else {
      FilterConfigResponse response;
      response.msg_type = MSG_TYPE_ERROR;
      response.status_code = EXIT_FAILURE;
      send(Active_Socket, (char *)&response, sizeof(response), 0);
      close(Active_Socket);
      Active_Socket = -1;
      continue;
    }

    OSSemPost(Wake_RX_Sem);
    OSSemPost(Wake_TX_Sem);

    OSSemPend(Disconnect_Sem, 0, &error_code);

    close(Active_Socket);
    Active_Socket = -1;

    {
      AudioDataRequest *leakedMessages;
      // Drain RX Queue
      while ((leakedMessages = (AudioDataRequest *)OSQAccept(
                  RX_to_Process_Queue, &error_code)) != (void *)0) {
        delete leakedMessages;
      }
    }

    {
      AudioDataResponse *leakedMessages;
      // Drain TX Queue
      while ((leakedMessages = (AudioDataResponse *)OSQAccept(
                  Process_to_TX_Queue, &error_code)) != (void *)0) {
        delete leakedMessages;
      }
    }

    clear_fir();
  }
}

int main(int argc, char *argv[], char *envp[]) {
  INT8U error_code;
  OSTimeSet(0);

  Wake_RX_Sem = OSSemCreate(0);
  Wake_TX_Sem = OSSemCreate(0);
  Disconnect_Sem = OSSemCreate(0);
  RX_to_Process_Queue = OSQCreate((void **)&RXtoProcessBuffer, QUEUE_BUFF_SIZE);
  Process_to_TX_Queue = OSQCreate((void **)&ProcesstoTXBuffer, QUEUE_BUFF_SIZE);

  OSTaskCreate(RX_Task, (void *)0, &RX_Task_Stk[TASK_STACK_SIZE - 1],
               RX_TASK_PRIO);

  OSTaskCreate(Processing_Task, (void *)0,
               &Process_Task_Stk[TASK_STACK_SIZE - 1], PROCESS_TASK_PRIO);

  OSTaskCreate(TX_Task, (void *)0, &TX_Task_Stk[TASK_STACK_SIZE - 1],
               TX_TASK_PRIO);

  error_code = OSTaskCreateExt(
      SSSInitialTask, NULL, (OS_STK *)&SSSInitialTaskStk[TASK_STACKSIZE],
      SSS_INITIAL_TASK_PRIORITY, SSS_INITIAL_TASK_PRIORITY, SSSInitialTaskStk,
      TASK_STACKSIZE, NULL, 0);
  alt_uCOSIIErrorHandler(error_code, 0);
  OSStart();
  while (1)
    ;
  return -1;
}
