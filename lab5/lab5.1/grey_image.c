#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#define STB_IMAGE_IMPLEMENTATION
#include "../stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../stb/stb_image_write.h"

extern void enGrey(unsigned char*, unsigned int, unsigned int);
unsigned char max(unsigned char, unsigned char, unsigned char );
void greee(unsigned char*, unsigned int, unsigned int);

unsigned char max(unsigned char a, unsigned char b, unsigned char c){
    if(a > b){
        b = a;
    }
    if(b < c){
        b = c;
    }
    return b;
}

void greee(unsigned char* buf, unsigned int w, unsigned int h){
    int tmp;
    unsigned char m;
    for(int x = 0; x <= w; x++){
        for(int y = 0; y <= h; y++){
            tmp = 3*(y * w + x);
            m = max(buf[tmp], buf[tmp+1], buf[tmp+2]);
            *(buf + tmp)     = m;
            *(buf + tmp + 1) = m;
            *(buf + tmp + 2) = m;
        }
    }
}

int main(int argc, char** argv){
	char* input = 0;
	char* output = 0;

	int width, height, channels;
	int newWidth, newHeight;
    unsigned int lbound, stripewidth;

	if (argc != 3){
		fprintf(stderr, "Usage: %s <input> <output> <pixfromleft> <width>\n", argv[0]);
		exit(-1);
	}

	input = argv[1];
	output = argv[2];
	char* ptr;
    

	if (access(input, F_OK) != 0){
		fprintf(stderr, "Input file does not exist\n");
		exit(-1);
	}

	int fd = 0;
	if ((fd = open(output, O_CREAT | O_WRONLY | O_TRUNC, 0644)) == -1){
		fprintf(stderr, "Can't open output for writing\n");
		exit(-1);
	}

	close(fd);
	unsigned char* inputData = stbi_load(input, &width, &height, &channels, 0);

	if (!inputData){
		fprintf(stderr, "Couldn't load the image\n");
		exit(-1);
	}
	printf("%s\n", output);
    
    struct timespec t, t1, t2;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
    enGrey(inputData, width, height);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
    t.tv_sec=t2.tv_sec-t1.tv_sec;
    
    if((t.tv_nsec = t2.tv_nsec - t1.tv_nsec) < 0){
        t.tv_sec--;
        t.tv_nsec += 1000000000;
    }
    printf("Convertion on C: %ld.%.9ld\n", t.tv_sec, t.tv_nsec);
    stbi_write_jpg(output, width, height, channels, inputData, 100);
	stbi_image_free(inputData);

	inputData = stbi_load(input, &width, &height, &channels, 0);
	printf("%s\n", output);

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
    greee(inputData, width, height);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
    t.tv_sec = t2.tv_sec - t1.tv_sec;
    if((t.tv_nsec = t2.tv_nsec - t1.tv_nsec) < 0){
        t.tv_sec--;
        t.tv_nsec += 1000000000;
    }
    printf("Convertion on asm: %ld.%.9ld\n", t.tv_sec, t.tv_nsec);
	stbi_write_jpg(output, width, height, channels, inputData, 100);
}
