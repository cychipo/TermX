#ifndef VTUTIL_H
#define VTUTIL_H

#include <stdint.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

int termx_open_pty(int *master_fd, pid_t *child_pid, const char *shell_path, const char *term_name, int columns, int rows);
int termx_resize_pty(int master_fd, int columns, int rows);

#ifdef __cplusplus
}
#endif

#endif
