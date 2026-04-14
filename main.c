#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <getopt.h>

#define DEFAULT_BLOCK_SIZE 4096

int main(int argc, char *argv[]) {
    int opt;
    size_t block_size = DEFAULT_BLOCK_SIZE;

    while ((opt = getopt(argc, argv, "b:")) != -1) {
        switch (opt) {
            case 'b':
                block_size = (size_t)atoi(optarg);
                if (block_size == 0) {
                    fprintf(stderr, "Invalid block size: %s\n", optarg);
                    return 1;
                }
                break;
            default:
                fprintf(stderr, "Usage: %s [-b block_size] [input] output\n", argv[0]);
                return 1;
        }
    }

    int input_fd, output_fd;
    unsigned char *buffer;
    const char *output_path;

    if (argc - optind == 1) {
        input_fd = STDIN_FILENO;
        output_path = argv[optind];
    } else if (argc - optind == 2) {
        const char *input_path = argv[optind];
        output_path = argv[optind + 1];

        input_fd = open(input_path, O_RDONLY);
        if (input_fd == -1) {
            perror("open input file");
            return 1;
        }
    } else {
        fprintf(stderr, "Usage: %s [-b block_size] [input] output\n", argv[0]);
        return 1;
    }

    output_fd = open(output_path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (output_fd == -1) {
        perror("open output file");
        goto cleanup_and_exit;
    }

    buffer = malloc(block_size);
    if (!buffer) {
        perror("malloc");
        goto cleanup_and_exit;
    }

    off_t total_bytes_read = 0;
    ssize_t bytes_read;
    while ((bytes_read = read(input_fd, buffer, block_size)) > 0) {
        total_bytes_read += bytes_read;
        int is_zero_block = 1;
        for (ssize_t i = 0; i < bytes_read; ++i) {
            if (buffer[i] != 0) {
                is_zero_block = 0;
                break;
            }
        }

        if (is_zero_block) {
            if (lseek(output_fd, bytes_read, SEEK_CUR) != (off_t)-1) continue;

            perror("lseek");
            goto cleanup_and_exit;
        } else {
            ssize_t written = write(output_fd, buffer, bytes_read);
            if (written == bytes_read) continue;
            
            perror("write");
            goto cleanup_and_exit;
        }
    }

    if (bytes_read == -1) {
        perror("read");
        goto cleanup_and_exit;
    }

    if (ftruncate(output_fd, total_bytes_read) == -1) {
        perror("ftruncate");
        goto cleanup_and_exit;
    }

    free(buffer);
    if (input_fd != STDIN_FILENO) close(input_fd);
    if (close(output_fd) == -1) {
        perror("close output");
        return 1;
    }

    return 0;

cleanup_and_exit:
    if (buffer) free(buffer);
    if (input_fd != STDIN_FILENO) close(input_fd);
    if (output_fd != -1) close(output_fd);
    return 1;
}
