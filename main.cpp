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

    ERROR_HANDLER ( MyPrintf ("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, -1, "love", 3802, 100, 33, 127,
                                                                         -1, "love", 3802, 100, 33, 127))
    float fnum = -123.7;

    ERROR_HANDLER ( MyPrintf ("%f\n", fnum))

    return EXIT_SUCCESS;
}

#undef ERROR_HANDLER
