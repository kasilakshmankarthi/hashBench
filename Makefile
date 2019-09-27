# Copyright (c) 2018 SARC
# All Rights Reserved.
# Confidential and Proprietary - SARC.

PROG1 = hashBench.elf

ifeq ($(ARCH),arm64)
  COMPILER=~/bin/ndk21-arm64/bin/aarch64-linux-android-
  INC=~/bin/ndk21-arm64/lib64/clang/6.0.2/include/arm_acle.h
endif

CC  = $(COMPILER)clang
CXX = $(COMPILER)clang

#-ggdb
ifeq ($(ARCH),arm64)
    CFLAGS = -O3 -v -march=armv8-a+crc+crypto -D__ARM_FEATURE_CRC32 -Wall -Wno-shift-count-overflow -I${INC}
endif

ifeq ($(ARCH),arm64)
  LDFLAGS = -static -flto
endif

all: $(PROG1)

SRC1 = city.cc hashBench.cc
OBJS1 = $(SRC1:.cpp=.o)

$(PROG1): $(SRC1)
	#rm -f $(PROG1) $(OBJS1)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	#rm $(PROG1) $(OBJS1)
