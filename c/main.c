#include <ncurses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void mssleep(int milliseconds);
bool loop(NCURSES_SIZE_T maxx, NCURSES_SIZE_T maxy);
#define randx(maxx) rand() % ((maxx) + 1)

int main() {
  // Seed the random number generator
  srand(time(NULL));

  // set up ncurses data structures
  initscr();

  // 0 = invisible
  // 1 = normal
  // 2 = very visible
  curs_set(0);

  // on a call to wgetch, don't block on input
  nodelay(stdscr, true);
  // don't buffer stdin until enter pressed
  cbreak();
  noecho();
  NCURSES_SIZE_T maxx = stdscr->_maxx;
  NCURSES_SIZE_T maxy = stdscr->_maxy;
  //printw("%d, %d\n", maxx, maxy);

  bool isDone = false;
  while (loop(maxy, maxx)) {
    mssleep(35);
  }

  endwin();
  return 0;
}

bool loop(NCURSES_SIZE_T maxy, NCURSES_SIZE_T maxx) {
  static int curx = -1;
  static int cury = -1;

  cury += 1;
  if (curx < 0) {
    curx = randx(maxx);
  }
  if (cury > maxy) {
    cury = 0;
    curx = randx(maxx);
  }
  werase(stdscr);
  clearok(stdscr, true);

  int result = wgetch(stdscr);
  if (result != ERR){
    return false;
  }

  move(cury, curx);
  wechochar(stdscr, 'X');
  ////addstr("Hello, world!"); // macro
  ////#define addstr(str)		waddnstr(stdscr,(str),-1)
  //waddnstr(stdscr, "Hello, world!\n", -1);

  //// sync from current screen to standard screen
  ////refresh(); // macro
  ////#define refresh()		wrefresh(stdscr)
  //wrefresh(stdscr);

  return true;
}

void mssleep(int milliseconds) {
  struct timespec ts = {
    .tv_sec = 0,
    .tv_nsec = milliseconds * 1000000,
  };

  nanosleep(&ts, NULL);
}

char * dynamicformat(char * fmtstr, ...) {
  size_t needed = snprintf(NULL, 0, fmtstr);
}
