CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = sparcify

build: main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c

clean:
	rm -f $(TARGET)