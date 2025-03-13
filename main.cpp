#include "myprintf.h"

#include <stdlib.h>

#define ERROR_HANDLER(func)                         \
    error = func;                                   \
    if (error != kDone)                             \
    {                                               \
        fprintf (stderr, "Error number = {%d}\n");  \
        return EXIT_FAILURE;                        \
    }

int main ()
{
    enum MyPrintfError error = kDone;
    MyPrintf ("1234567890");
    MyPrintf ("1234567890");

    return EXIT_SUCCESS;
}

#undef ERROR_HANDLER
