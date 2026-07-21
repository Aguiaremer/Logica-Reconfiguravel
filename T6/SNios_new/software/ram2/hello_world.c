#include <stdio.h>
#include <string.h>
#include "system.h"
#include "io.h"

#define REG_ADD      0   
#define REG_DATA     4   
#define REG_CTRL     8   

#define WE_MEM       (1 << 0) 
#define RD_MEM       (1 << 1) 
#define CLR_CHK      (1 << 2) 

void hw_write_byte(unsigned int addr, unsigned char data) {
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_ADD, addr);
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_DATA, (unsigned int)data);
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_CTRL, WE_MEM);
}

unsigned char hw_read_byte(unsigned int addr) {
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_ADD, addr);
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_CTRL, RD_MEM);
    // Delay para o hardware processar a leitura síncrona
    volatile int d; for(d=0; d<50; d++); 
    return (unsigned char)IORD_32DIRECT(TOP_AVALON_0_BASE, REG_DATA);
}

int main()
{
    // String exata do projeto
    const char nome_str[] = " JEAN CARLOS DO NASCIMENTO CUNHA  +++--+++ ";
    int str_len = strlen(nome_str);
    
    unsigned char seq_num = 1;
    unsigned int sw_sum = 0;
    unsigned char sw_checksum = 0;
    
    int i;

    printf("\n=== PROJETO BRAM NIOS II - JEAN CARLOS ===\n");
    printf("String: [%s]\n", nome_str);
    printf("Tamanho: %d bytes\n", str_len);

    // 1. Reset do Hardware
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_CTRL, CLR_CHK);

    // 2. Escrita e Cálculo do Checksum
    printf("Escrevendo na BRAM...\n");
    for (i = 0; i < str_len; i++) {
        unsigned char b = (unsigned char)nome_str[i];
        hw_write_byte(i, b);
        sw_sum += b;
    }
    sw_checksum = (unsigned char)(sw_sum & 0xFF);

    // 3. Handshake
    unsigned int cmd = ((unsigned int)seq_num << 24) | ((unsigned int)sw_checksum << 16);
    IOWR_32DIRECT(TOP_AVALON_0_BASE, REG_CTRL, cmd);

    // Pequena pausa para o hardware atualizar o bit de match
    for(i=0; i<100; i++);

    // 4. Leitura do Status
    unsigned int status = IORD_32DIRECT(TOP_AVALON_0_BASE, REG_CTRL);
    unsigned char hw_chk = (unsigned char)((status >> 8) & 0xFF);
    unsigned char match  = (unsigned char)((status >> 7) & 0x01);

    printf("-------------------------------------------\n");
    printf("SEQUENCIA: %d\n", seq_num);
    printf("SUM TOTAL: %u\n", sw_sum);
    printf("SW CHECKSUM: 0x%02X\n", sw_checksum);
    printf("HW CHECKSUM: 0x%02X\n", hw_chk);
    printf("RESULTADO: %s\n", match ? "SUCESSO (MATCH!)" : "ERRO (MISMATCH)");
    printf("-------------------------------------------\n");

    // 5. Leitura para Verificação Visual no Modelsim
    printf("Iniciando leitura para validacao visual...\n");
    for (i = 0; i < str_len; i++) {
        unsigned char lido = hw_read_byte(i);
        // Opcional: imprimir para o console (descomente se quiser ver na UART)
        // printf("%c", lido);
    }
    printf("\nFim da simulação.\n");

    while(1);
    return 0;
}
