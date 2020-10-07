#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <CoreFoundation/CoreFoundation.h>

char *begin_with_filepath(const char *filepath, int size);

void filepath_free(char *s);

void register_callback(void (*callback)(CFStringRef));
