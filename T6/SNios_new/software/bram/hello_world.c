/*
 * BRAM test application
 * Author: JEAN CARLOS DO NASCIMENTO CUNHA
 *
 * Behavior:
 * - Repeats the full name in ASCII into a 1024-byte block (with separators)
 * - Writes 1024 bytes to the user BRAM via registers at offsets:
 *     ADD=00 -> address (IOWR base,0)
 *     ADD=01 -> data    (IOWR base,1)
 *     ADD=10 -> control (IOWR base,2)  bit1=WE, bit0=RD (self-clear in HW)
 * - After 1024 writes computes checksum (16-bit) and sends sequence+checksum to UART
 * - Reads back 1024 bytes, computes checksum and compares with written checksum
 * - Reports result via UART and repeats with incremented sequence number
 */

#include <stdint.h>
#include "io.h"
#include "system.h"
#include "altera_avalon_jtag_uart_regs.h"

#define BLOCK_SIZE 1024

static void uart_putc(char c)
{
  while ((IORD_ALTERA_AVALON_JTAG_UART_CONTROL(JTAG_UART_0_BASE) &
          ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_MSK) == 0) {
  }
  IOWR_ALTERA_AVALON_JTAG_UART_DATA(JTAG_UART_0_BASE, (uint32_t)c);
}

static void uart_puts(const char *s)
{
  while (*s != '\0') {
    if (*s == '\n') {
      uart_putc('\r');
    }
    uart_putc(*s++);
  }
}

static void uart_put_hex16(uint16_t value)
{
  int shift;
  for (shift = 12; shift >= 0; shift -= 4) {
    unsigned int digit = (unsigned int)((value >> shift) & 0xF);
    uart_putc((char)(digit < 10 ? ('0' + digit) : ('A' + digit - 10)));
  }
}

static void uart_put_u16(uint16_t value)
{
  char digits[6];
  int pos = 0;
  if (value == 0) {
    uart_putc('0');
    return;
  }
  while (value > 0 && pos < (int)sizeof(digits)) {
    digits[pos++] = (char)('0' + (value % 10));
    value /= 10;
  }
  while (pos > 0) {
    uart_putc(digits[--pos]);
  }
}

int main()
{
  unsigned int i;
  uint8_t buffer[BLOCK_SIZE];
  uint8_t readbuf[BLOCK_SIZE];
  /* Pattern: full name (no accents) + separator of 10 chars (space +++--+++ space) */
  const char *name = "JEAN CARLOS DO NASCIMENTO CUNHA";
  const char *sep  = " +++--+++ "; /* 9 chars including spaces; will be used as given */
  unsigned int namelen = 0;
  unsigned int seplen = 0;
  unsigned int idx = 0;
  uint32_t checksum_write = 0;
  uint32_t checksum_read = 0;
  uint16_t seq = 1;

  for (namelen = 0; name[namelen] != '\0'; ++namelen);
  for (seplen = 0; sep[seplen] != '\0'; ++seplen);

  /* Build repeating buffer: name, space, sep, space, name, ... */
  idx = 0;
  for (i = 0; i < BLOCK_SIZE; ++i) {
    unsigned int pos = idx;
    if (pos < namelen) {
      buffer[i] = (uint8_t)name[pos];
    } else if (pos < namelen + seplen) {
      buffer[i] = (uint8_t)sep[pos - namelen];
    } else {
      /* wrap around */
      idx = 0;
      if (idx < namelen) buffer[i] = (uint8_t)name[idx++]; else buffer[i] = ' ';
      continue;
    }
    idx++;
    if (idx >= namelen + seplen) idx = 0;
  }

  while (1) {
    checksum_write = 0;

    /* write 1024 bytes */
    for (i = 0; i < BLOCK_SIZE; ++i) {
      /* write address */
      IOWR(TOP_AVALON_0_BASE, 0, i);
      /* write data (lower byte) */
      IOWR(TOP_AVALON_0_BASE, 1, buffer[i]);
      /* issue WE (bit1 = 1) */
      IOWR(TOP_AVALON_0_BASE, 2, 0x2);
      checksum_write += buffer[i];
    }
    checksum_write &= 0xFFFF;

    /* report sequence and checksum to UART */
    uart_puts("SEQ=");
    uart_put_u16(seq);
    uart_puts(" CHECKSUM=0x");
    uart_put_hex16((uint16_t)checksum_write);
    uart_puts("\n");

    /* read back 1024 bytes */
    checksum_read = 0;
    for (i = 0; i < BLOCK_SIZE; ++i) {
      /* set address */
      IOWR(TOP_AVALON_0_BASE, 0, i);
      /* issue RD (bit0 = 1) */
      IOWR(TOP_AVALON_0_BASE, 2, 0x1);

      /* poll status at ADD=10 until read_valid (bit0) is set */
      {
        unsigned int status = 0;
        do {
          status = IORD(TOP_AVALON_0_BASE, 2);
        } while ((status & 0x1) == 0);
      }

      /* read data at ADD=01 */
      {
        unsigned int val = IORD(TOP_AVALON_0_BASE, 1);
        readbuf[i] = (uint8_t)(val & 0xFF);
        checksum_read += readbuf[i];
      }
    }
    checksum_read &= 0xFFFF;

    /* compare and report */
    if ((uint16_t)checksum_read == (uint16_t)checksum_write) {
      uart_puts("SEQ=");
      uart_put_u16(seq);
      uart_puts(" OK CHECKSUM=0x");
      uart_put_hex16((uint16_t)checksum_read);
      uart_puts("\n");
    } else {
      uart_puts("SEQ=");
      uart_put_u16(seq);
      uart_puts(" MISMATCH W=0x");
      uart_put_hex16((uint16_t)checksum_write);
      uart_puts(" R=0x");
      uart_put_hex16((uint16_t)checksum_read);
      uart_puts("\n");
    }

    seq++;
    /* wait a bit before next block */
    {
      volatile unsigned int d;
      for (d = 0; d < 100000; ++d) ;
    }
  }

  return 0;
}
