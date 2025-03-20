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

        CASE_ENUM_ (kInvalidSpecifierPrintf);

        CASE_ENUM_ (kSyscallErrorPrintf);

        CASE_ENUM_ (kInvalidColorPrintf);

        default:
            return "Invalid enum element";
    }

    #undef CASE_ENUM_
}
