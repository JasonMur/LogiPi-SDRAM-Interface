
//Simple program for reading and writing data pattern to the SPI Interface 


#include <stdio.h> 
#include <errno.h> 
#include <stdlib.h> 
#include <stdint.h> 
#include <fcntl.h> 
#include <unistd.h> 
#include <sys/ioctl.h> 
#include <linux/types.h> 
#include <linux/spi/spidev.h> 

static int fd = -1; 
int n,byte;
static void 
errxit(const char *msg) { 
	perror(msg); 
	exit(1); 
} 

int main(int argc, char ** argv) { 
	//system ("logi_loader ./top_level.bit");
	static uint8_t rx[] = {0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; 
	unsigned char  tx[32];// = {0xaa, 14, 0x55, 12, 0xaa, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
	int n = 0;
	int byte = 0;
	int ch = 0;
	FILE * dataFile = fopen("./dataFile.dat", "rb+");
	if (dataFile == NULL) return;
	fseek(dataFile, 0, SEEK_END);
	int fileLen = ftell(dataFile);
	printf("%d",fileLen);
//	return;
	fseek(dataFile, 0, SEEK_SET);

	struct spi_ioc_transfer ioc = { 
		ioc.tx_buf = (unsigned long) tx, 
		ioc.rx_buf = (unsigned long) rx, 
		ioc.len = 32, 
		ioc.speed_hz = 30000000, 
		ioc.delay_usecs = 10, 
		ioc.bits_per_word = 8, 
		ioc.cs_change = 1 
	};

	uint8_t mode = SPI_MODE_0; 
	int rc; 
 
	fd = open("/dev/spidev0.0",O_RDWR); 
	if ( fd < 0 ) 
		errxit("Opening SPI device."); 

	rc = ioctl(fd,SPI_IOC_WR_MODE,&mode); 

	if ( rc < 0 ) 
		errxit("ioctl (2) setting SPI mode."); 

	rc = ioctl(fd,SPI_IOC_WR_BITS_PER_WORD,&ioc.bits_per_word); 
	if ( rc < 0 ) 
		errxit("ioct1 (2) setting SPI bits perword."); 
	for (n=0;n<32000000;n++)
	{
		tx[byte]=fgetc(dataFile);
		byte = byte + 1;
		if (byte == 32)
		{
			byte = 0;
			ioc.tx_buf = (unsigned long) tx;
			rc = ioctl(fd,SPI_IOC_MESSAGE(1),&ioc); 
			if ( rc < 0 ) 
				errxit("ioctl (2) for SPI I/O"); 
			for (ch=0;ch<32;ch++)
				printf("%c",rx[ch]);
		}
		if (ftell(dataFile)>(fileLen-32))
			fseek(dataFile, 0, SEEK_SET);
	}
	
	close(fd); 
	
	fclose(dataFile);
	return 0; 
} 
