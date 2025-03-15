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
    int num = 0;
    ERROR_HANDLER ( MyPrintf ("123\n %n", &num))
    ERROR_HANDLER ( MyPrintf ("%d\n", num))

    return EXIT_SUCCESS;
}

#undef ERROR_HANDLER
