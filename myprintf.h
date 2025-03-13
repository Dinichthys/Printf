#ifndef MYPRINTF_H
#define MYPRINTF_H

enum MyPrintfError {
    kDone            = 0,
    kInvalidArgument = 1,
};

extern "C" enum MyPrintfError MyPrintf (const char* const format, ...);

#endif // MYPRINTF_H
