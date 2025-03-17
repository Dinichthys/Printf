#include "myprintf.h"

const char* EnumMyPrintfToStr (const enum MyPrintfError error)
{
    #define CASE_ENUM_(error)   \
    case error:                 \
    {                           \
        return #error;          \
    }

    switch (error)
    {
        CASE_ENUM_ (kDonePrintf);

        CASE_ENUM_ (kInvalidArgumentPrintf);

        CASE_ENUM_ (kSyscallError);

        default:
            return "Invalid enum element";
    }

    #undef CASE_ENUM_
}
