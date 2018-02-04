#include <termios.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include "posix_input.h"

static struct termios told, tnew;

void initTermios(int echo) 
{
  tcgetattr(0, &told);
  tnew = told;
  tnew.c_lflag &= ~ICANON;
  tnew.c_lflag &= echo ? ECHO : ~ECHO;
  tcsetattr(0, TCSANOW, &tnew); 
}

void resetTermios(void) 
{
  tcsetattr(0, TCSANOW, &told);
}

int getch_(int echo) 
{
  int ch;
  initTermios(echo);
  ch = getchar();
  resetTermios();
  return ch;
}

int getch(void) 
{
  return getch_(0);
}

int getche(void) 
{
  return getch_(1);
}

int kbhit(void)
{
    static const int STDIN = 0;
    static bool initialized = false;

    if (! initialized) {
        // Use termios to turn off line buffering
        termios term;
        tcgetattr(STDIN, &term);
        term.c_lflag &= ~ICANON;
        tcsetattr(STDIN, TCSANOW, &term);
        setbuf(stdin, NULL);
        initialized = true;
    }

    int bytesWaiting;
    ioctl(STDIN, FIONREAD, &bytesWaiting);
    return bytesWaiting;
}