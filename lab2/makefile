CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = lab2.s

OBJS = $(SRCS:.s=.o)

dec: $(SRCS) $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ 

lab2.o: lab2.s
	$(AS) $(ASFLAGS) $< -o lab2.o --defsym rev=1



inc: $(SRCS) lab12.o
	$(LD) $(LDFLAGS) lab12.o -o $@ 
	
lab12.o: lab2.s
	$(AS) $(ASFLAGS) $< -o lab12.o 


clean:
	rm -rf $(EXE) $(OBJS) inc dec *.o

