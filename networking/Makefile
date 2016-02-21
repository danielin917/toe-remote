# Enables C++11 -- don't touch these
PATH := /usr/um/gcc-4.7.0/bin:$(PATH)
LD_LIBRARY_PATH := /usr/um/gcc-4.7.0/lib64
LD_RUN_PATH := /usr/um/gcc-4.7.0/lib64

# Default Flags
FLAGS = -pthread -std=c++11 -Wall -Werror -pedantic -ldl -c -g
LFLAGS = -pedantic -Wall -ldl -pthread -std=c++11

CC = g++

PROG = run

SRC = $(shell find . -name *.cpp)

OBJS = ServerInterface.o 
#OBJS +=

default: $(PROG)

$(PROG): $(OBJS) main.o
	$(CC) $(OBJS) main.o $(LFLAGS) -o $(PROG)

ServerInterface.o: ServerInterface.h
	$(CC) $(FLAGS) ServerInterface.cpp
 
main.o: main.cpp
	g++ $(FLAGS) main.cpp

clean:
	rm -f proj2 *.o core.*

