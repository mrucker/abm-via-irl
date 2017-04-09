# Project: dTcmd
# (c) S. Ruggieri, 2002-2009
# compile 32 & 6 bit with: 
#    make EXTFLAGS=32
#    make clean
#    make EXTFLAGS=64

ROOT = ../../
INCYaDT = $(ROOT)include/
LIBHOME = $(ROOT)lib/
EXEHOME = $(ROOT)bin/

CC = g++

# add -pg to profile
PROFILE  = $(EXTPROF)

CPPFLAGS = -m$(EXTFLAGS) $(PROFILE) -ftemplate-depth-99 -Wall -Wno-non-template-friend -O4\
           -I $(INCYaDT)YaDT -finline-functions
LIBNAME = $(LIBHOME)libYaDT$(EXTFLAGS).a $(LIBHOME)rst/lib/librst$(EXTFLAGS).a $(LIBHOME)rst/lib/libz$(EXTFLAGS).a
LDFLAGS = -m$(EXTFLAGS) $(PROFILE) -L$(LIBHOME) -L$(LIBHOME)rst/lib/ -lYaDT$(EXTFLAGS)\
          -lrst$(EXTFLAGS) -lz$(EXTFLAGS) -lstdc++ -lpthread -lm

all: dTcmd
	mv dTcmd $(EXEHOME)dTcmd$(EXTFLAGS)

# executable dependecies
dTcmd: dTcmd.o $(LIBNAME)

# objects dependecies
dTcmd.o: dTcmd.cpp

.PHONY: clean

clean:
	rm -f *.o *~


