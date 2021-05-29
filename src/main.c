#include <stdio.h>
#include <stdlib.h>
#include "../librubyfmt/include/rubyfmt.h"

int main() {
    int buf_size = 1024;
    int bytes_read = 0;
    unsigned char* buf = malloc(sizeof(char)*buf_size);
    int nread = fread(buf, sizeof(char), buf_size, stdin);
    while (nread == buf_size) {
        bytes_read += nread;
        int old_buf_size = buf_size;
        buf_size *= 2;
        buf = realloc(buf, sizeof(char)*buf_size);
        nread = fread(buf+bytes_read, sizeof(char), buf_size-old_buf_size, stdin);
    }
    bytes_read += nread;

    int res = rubyfmt_init();
    if (res != RUBYFMT_INIT_STATUS_OK) {
        fprintf(stderr, "failed to init\n");
        exit(1);
    }
    enum Rubyfmt_FormatError status = RUBYFMT_FORMAT_ERROR_OK;
    RubyfmtString* out = rubyfmt_format_buffer(buf, bytes_read, &status);
    if (status != 0) {
        exit(status);
    }
    unsigned char* bytes = rubyfmt_string_ptr(out);
    size_t len = rubyfmt_string_len(out);
    fwrite(bytes, sizeof(char), len, stdout);
    rubyfmt_string_free(out);
}
