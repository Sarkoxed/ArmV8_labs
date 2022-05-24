CROSS_COMPILE ?= aarch64-linux-gnu-
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

NAME = $(shell basename $(shell pwd))
SRCS = $(NAME).s
OBJS = $(SRCS:.s=.o)
EXE = $(SRCS:.s=.out)


all: $(SRCS) $(EXE)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf *.o *.out


