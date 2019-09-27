LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)
LOCAL_MODULE_TAGS := release
LOCAL_MODULE := hashBench
LOCAL_CPP_EXTENSION := \
   .cc \
   .cpp

LOCAL_CFLAGS := -O3 -march=armv8-a+crc+crypto -mfpu=neon -Wall -Werror -Wno-shift-count-overflow

LOCAL_SRC_FILES := \
    city.cc \
    hashBench.cc

include $(BUILD_EXECUTABLE)
