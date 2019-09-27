#include <cstdlib>
#include <ctime>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <sched.h>
#include <sys/resource.h>
#include <ctype.h>

#include <arm_acle.h>

#define USEC_PER_SEC 1000000ULL
#define SPA
#define CRC32HW

// Contains information about benchmark options.
typedef struct {
  int cpu_to_lock;
  int locked_freq;
} command_data_t;

int buff_sz = 0;

void usage() {
  printf("--------------------------------------------------------------------------------\n");
  printf("Usage:");
  printf("    hashBench [--buff_sz bytes] [--cpu_to_lock CPU] [--locked_freq FREQ_IN_KHZ]\n\n");
  printf("!!!!!!Lock the desired core to a desired frequency before invoking this benchmark.\n");
  printf("Hint: Set scaling_max_freq=scaling_min_freq=FREQ_IN_KHZ. FREQ_IN_KHZ "
          "can be obtained from scaling_available_freq\n");
  printf("--------------------------------------------------------------------------------\n");
}

int processOptions(int argc, char **argv, command_data_t *cmd_data) {
  // Initialize the command_flags.
  cmd_data->cpu_to_lock = 0;
  cmd_data->locked_freq = 1;

  for (int i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      int *save_value = NULL;
      if (strcmp(argv[i], "--cpu_to_lock") == 0) {
        save_value = &cmd_data->cpu_to_lock;
      } else if (strcmp(argv[i], "--locked_freq") == 0) {
        save_value = &cmd_data->locked_freq;
      } else if (strcmp(argv[i], "--buff_sz") == 0) {
        save_value = &buff_sz;
      } else {
        printf("Unknown option %s\n", argv[i]);
        return -1;
      }

      if (save_value) {
        // Checking both characters without a strlen() call should be
        // safe since as long as the argument exists, one character will
        // be present (\0). And if the first character is '-', then
        // there will always be a second character (\0 again).
        if (i == argc - 1 ||
          (argv[i + 1][0] == '-' && !isdigit(argv[i + 1][1]))) {
          printf("The option %s requires one argument.\n", argv[i]);
          return -1;
        }

        *save_value = (int)strtol(argv[++i], NULL, 0);
      }
    }
  }

  return 0;
}

