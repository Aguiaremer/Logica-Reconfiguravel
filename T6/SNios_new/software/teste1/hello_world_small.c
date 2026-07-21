#include <stdio.h>
#include <stdint.h>
#include "io.h"
#include "system.h"

#define BLOCK_SIZE 1024

int main()
{
    unsigned int i;
    uint8_t buffer[BLOCK_SIZE];
    uint8_t readbuf[BLOCK_SIZE];
    const char *pattern = " JOAO DA SILVA +++--+++ ";
    unsigned int patlen = 0;
    unsigned int idx = 0;
    uint32_t checksum_write = 0;
    uint32_t checksum_read = 0;
    uint16_t seq = 1;

    /* build buffer repeating the pattern */
    for (patlen = 0; pattern[patlen] != '\0'; ++patlen);
    for (i = 0; i < BLOCK_SIZE; ++i) {
        buffer[i] = (uint8_t)pattern[idx++ % patlen];
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
        printf("SEQ=%u CHECKSUM=0x%04X\n", seq, (unsigned)checksum_write);

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
            printf("SEQ=%u OK CHECKSUM=0x%04X\n", seq, (unsigned)checksum_read);
        } else {
            printf("SEQ=%u MISMATCH W=0x%04X R=0x%04X\n", seq, (unsigned)checksum_write, (unsigned)checksum_read);
        }

        seq++;
        /* wait a bit before next block */
        for (volatile unsigned int d=0; d<100000; ++d);
    }

    return 0;
}
