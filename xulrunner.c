#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mach-o/dyld.h>

/* int main(int argc, char **argv) { */
/*   char path[1024]; */
/*   uint32_t size = sizeof(path); */
/*   if (_NSGetExecutablePath(path, &size) == 0) */
/*     printf("executable path is %s\n", path); */
/*   else */
/*     printf("buffer too small; need size %u\n", size); */
/* } */

#define FIREFOX_BINARY "xulrunner"
#define APPLICATION_INI "conkeror/application.ini"
#define APP " -app "

int main(int argc, char **argv) {
  char *path = NULL;
  char *command_line = NULL;
  uint32_t size = 0;
  int i;
  _NSGetExecutablePath(path, &size);
  path = (char *)malloc((size_t) size+1);
  if (_NSGetExecutablePath(path, &size) == 0) {
    for (i = strlen(path)-1; i > 0 && path[i] != '/'; i--)
      ;
    path[i+1] = '\0';
    /* printf("executable path is %s\n", path); */
    command_line = (char *)malloc((size_t)(2*size
                                           + strlen(FIREFOX_BINARY)
                                           + strlen(APP)
                                           + strlen(APPLICATION_INI)
                                           + 1));
    if (command_line != NULL) {
      strcpy(command_line, path);
      strcat(command_line, FIREFOX_BINARY);
      strcat(command_line, APP);
      strcat(command_line, path);
      strcat(command_line, APPLICATION_INI);
      /* printf("%s\n", command_line); */
      system(command_line);
    }
  }
}
