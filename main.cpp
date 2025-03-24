#include "myprintf.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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
//     ERROR_HANDLER (MyPrintf ("1234567890\n"))
//     int num = 0;
//     ERROR_HANDLER ( MyPrintf ("123\n %n", &num))
//     ERROR_HANDLER ( MyPrintf ("%d\n", num))
//
//     ERROR_HANDLER ( MyPrintf ("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, -1, "love", 3802, 100, 33, 127,
//                                                                          -1, "love", 3802, 100, 33, 127))
    float fnum = -123.7;

    FILE* out = fopen ("Output.html", "w");
    if (out == NULL)
    {
        fprintf (stderr, "Can't open output file\n");
    }
    // FILE* out = stdout;

//     ERROR_HANDLER ( MY_PRINTF (out, "\nMy Printf: \n1: %f\n"
//                               "2: %f\n"
//                               "3: %f\n"
//                               "4: %f\n"
//                               "5: %f\n"
//                               "6: %f\n"
//                               "7: %f\n"
//                               "8: %f\n"
//                               "9: %f\n"
//                               "c: %c\n"
//                               "10: %f\n"
//                               "11: %f\n"
//                               "12: %f\n\n"
//                               "\n\n"
//                               "%d %s %x %d%%%c%b\n"
//                               , fnum, fnum, fnum, fnum
//                               , fnum, fnum, fnum, fnum
//                               , fnum, 'a', fnum, 1.7, 1.23, -1, "love", 3802, 100, 33, 126))
//
//     printf ("\nOriginal Printf: \n1: %f\n"
//                               "2: %f\n"
//                               "3: %f\n"
//                               "4: %f\n"
//                               "5: %f\n"
//                               "6: %f\n"
//                               "7: %f\n"
//                               "8: %f\n"
//                               "9: %f\n"
//                               "c: %c\n"
//                               "10: %f\n"
//                               "11: %f\n"
//                               "12: %f\n"
//                               , fnum, fnum, fnum, fnum
//                               , fnum, fnum, fnum, fnum
//                               , fnum, 'a', fnum, 1.7, 1.23);
//
//     ERROR_HANDLER ( MY_PRINTF (out, "\nMy Printf: \n%d\n"
//                               "%d\n"
//                               "%f\n"
//                               "%f\n", __INT_MAX__, -__INT_MAX__, 102020290.1092920, 1.23456))
//
//     printf ("\nOriginal Printf: \n%d\n"
//                               "%d\n"
//                               "%f\n"
//                               "%f\n", __INT_MAX__, -__INT_MAX__, 102020290.1092920, 1.23456);

    MY_PRINTF (out, "\nMy Printf: \n#r%f #y%f #w%f #b%f\n"
                              "#g%d %s %x %d%%%c%b\n", NAN, -NAN, INFINITY, -INFINITY, -1, "love", 3802, 100, 33, 126);
//
//     printf ("\nOriginal Printf: \n%f %f %f %f\n", NAN, -NAN, INFINITY, -INFINITY);
//
//     MY_PRINTF (out, "\nMy Printf: \n%f \n", 0.00001);
//
//     printf ("\nOriginal Printf: \n%f \n", 0.00001);
//


    return EXIT_SUCCESS;
}

#undef ERROR_HANDLER
