#include <stdio.h>

static void bar(void) {
  printf("Inside of bar()\n");
}

int main() {
  printf("Calling bar...\n");
  bar();

  return 0;
}
