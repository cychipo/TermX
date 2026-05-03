#include "vtutil.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>
#include <util.h>

int termx_open_pty(int *master_fd, pid_t *child_pid, const char *shell_path, const char *term_name, int columns, int rows) {
    if (master_fd == NULL || child_pid == NULL || shell_path == NULL) {
        errno = EINVAL;
        return -1;
    }

    struct winsize size;
    memset(&size, 0, sizeof(size));
    size.ws_col = (unsigned short)columns;
    size.ws_row = (unsigned short)rows;

    pid_t pid = forkpty(master_fd, NULL, NULL, &size);
    if (pid < 0) {
        return -1;
    }

    if (pid == 0) {
        if (term_name != NULL) {
            setenv("TERM", term_name, 1);
        }
        setenv("LANG", "en_US.UTF-8", 1);
        setenv("LC_CTYPE", "UTF-8", 1);
        unsetenv("LC_ALL");
        const char *home = getenv("HOME");
        if (home != NULL && home[0] != '\0') {
            chdir(home);
        }
        execl(shell_path, shell_path, "-l", NULL);
        _exit(127);
    }

    *child_pid = pid;
    return 0;
}

int termx_resize_pty(int master_fd, int columns, int rows) {
    if (master_fd < 0 || columns <= 0 || rows <= 0) {
        errno = EINVAL;
        return -1;
    }

    struct winsize size;
    memset(&size, 0, sizeof(size));
    size.ws_col = (unsigned short)columns;
    size.ws_row = (unsigned short)rows;
    return ioctl(master_fd, TIOCSWINSZ, &size);
}
