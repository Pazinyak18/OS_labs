#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

int main() {
  char f1[] = "f1.txt";
  char f2[] = "f2.txt";

  int ret = 0;

  int infd = open(f1, O_RDONLY);
  if (infd == -1) {
    fprintf(stderr, "Failed to open %s (should exist)\n", f1);
    return 1;
  }

  int outfd = open(f2, O_WRONLY | O_CREAT | O_APPEND, S_IRWXU | S_IRGRP);
  if (infd == -1) {
    fprintf(stderr, "Failed to open %s\n", f2);
    return 1;
  }

  struct stat infilestat;

  if (fstat(infd, &infilestat) == -1) {
    fprintf(stderr, "Failed to get stat for %s\n", f1);
    ret = 1;
    goto end;
  }

  char* buffer = malloc(infilestat.st_size + 1);
  if (!buffer) {
    fprintf(stderr, "Failed to allocate %lld bytes\n", infilestat.st_size+1);
    ret = 1;
    goto end;
  }

  memset(buffer, 0, infilestat.st_size + 1);

  if (read(infd, buffer, infilestat.st_size) != infilestat.st_size) {
    fprintf(stderr, "Failed to read %lld chars from %s\n", infilestat.st_size, f1);
    ret = 1;
    goto end_mem;
  }

  if (write(outfd, buffer, infilestat.st_size) == -1) {
    fprintf(stderr, "Failed to write %lld chars to %s\n", infilestat.st_size, f2);
    ret = 1;
  }

end_mem:
  free(buffer);
end:
  close(infd);
  close(outfd);
  return ret;
}
