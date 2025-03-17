#ifndef MYPRINTF_H
#define MYPRINTF_H

enum MyPrintfError
{
    kDonePrintf              = 0,
    kInvalidSpecifierPrintf  = 1,
    kSyscallErrorPrintf      = 2
};

extern "C" enum MyPrintfError MyPrintf (const char* const format, ...);
const char* EnumMyPrintfToStr (const enum MyPrintfError error);

#endif // MYPRINTF_H
