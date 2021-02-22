#include <stdio.h>

#include "uses_header.h"

int main() {
  printf("Hello world\n");
  exported_function();
}

/// Implementation documentation
void exported_function(void) {
  printf("Exported!");
}

/// Documentation for static function
void static static_function(void) {
}
