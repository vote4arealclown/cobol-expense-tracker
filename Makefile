# COBOL Expense Tracker Makefile

CC = cobc
CFLAGS = -x -Wall -ftext-column=255
TARGET = expense-tracker
SOURCE = expense-tracker.cob

.PHONY: all build run clean

all: build

build:
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

run: build
	./$(TARGET)

clean:
	rm -f $(TARGET)
