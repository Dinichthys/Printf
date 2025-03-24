#ifndef MYPRINTF_H
#define MYPRINTF_H

enum MyPrintfError
{
    kDonePrintf              = 0,
    kInvalidSpecifierPrintf  = 1,
    kSyscallErrorPrintf      = 2,
    kInvalidColorPrintf      = 3
};

extern "C" enum MyPrintfError MyPrintf (int fd, const char* const format, ...) __attribute__((format (printf, 2, 3)));
const char* EnumMyPrintfToStr (const enum MyPrintfError error);

#define MY_PRINTF(FILE, FORMAT, ...) \
    MyPrintf (fileno (FILE), FORMAT, __VA_ARGS__);

#endif // MYPRINTF_H

// TODO  HTML теги для файла для вывода цвета
// TODO поменять %C на какой-нибудь знак пунктуации или сделать #r #b
// TODO добавить __attribute__((format (printf, 2, 3)))
