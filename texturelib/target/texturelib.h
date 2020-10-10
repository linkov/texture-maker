#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void begin_with_filepath(const char *filepath,
                         int size,
                         int out_size,
                         bool is_random,
                         bool is_detailed);

void filepath_free(char *s);

void register_callback(void (*callback)(CFStringRef));
