#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#define STB_IMAGE_IMPLEMENTATION
#include "../stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../stb/stb_image_write.h"

extern void greyStripe(unsigned char*, unsigned int, unsigned int, unsigned int, unsigned int);

int main(int argc, char** argv){
	char* input = 0;
	char* output = 0;

	int width, height, channels;
	int newWidth, newHeight;
    unsigned int lbound, stripewidth;

	if (argc != 5){
		fprintf(stderr, "Usage: %s <input> <output> <pixfromleft> <width>\n", argv[0]);
		exit(-1);
	}

	input = argv[1];
	output = argv[2];

	char *p;

    lbound = strtol(argv[3], &p, 10);
    stripewidth = strtol(argv[4], &p, 10);
    

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
    greyStripe(inputData, width, height, lbound, stripewidth);
    stbi_write_jpg(output, width, height, channels, inputData, 100);
    stbi_image_free(inputData);
}
