#include "myprintf.h"

#include <stdio.h>
#include <stdlib.h>

#define ERROR_HANDLER(func)                                 \
    error = func;                                           \
    if (error != kDonePrintf)                               \
    {                                                       \
        fprintf (stderr, "\nError number = {%d}\n"          \
                         "Error name   = \"%s\"\n",         \
                         error, EnumMyPrintfToStr (error)); \
        return EXIT_FAILURE;                                \
    }

int main ()
{
    enum MyPrintfError error = kDonePrintf;
    ERROR_HANDLER (MyPrintf ("1234567890\n"))
    ERROR_HANDLER ( MyPrintf ("%s\n", "123\n123%"))

    return EXIT_SUCCESS;
}

#undef ERROR_HANDLER
