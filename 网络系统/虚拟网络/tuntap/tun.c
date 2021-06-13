#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <sys/types.h>
#include <linux/if_tun.h>
#include <stdlib.h>
#include <stdio.h>

/*
 * 编译
 * gcc -o tun tun.c
 * 
 * 运行
 * ./tun
 * Open tun/tap device: tun0 for reading...
 */

int main()
{
    int err;

    int tun_fd;
    // 这是一个字符设备, 默认就存在于系统中(不管 lsmod 有没有加载 tun 模块)
    char *clonedev = "/dev/net/tun";
    tun_fd = open(clonedev, O_RDWR);
    if (tun_fd < 0) {
        return tun_fd;
    }

    struct ifreq ifr;
    // 重置内存
    memset(&ifr, 0, sizeof(ifr));
    /* Flags: IFF_TUN   - TUN device (no Ethernet headers)
     *        IFF_TAP   - TAP device
     *        IFF_NO_PI - Do not provide packet information
     */
    ifr.ifr_flags = IFF_TUN | IFF_NO_PI;

    // 这一步 ioctl() 创建了网络设备 - tun0
    // 多次运行该程序, 还会创建出 tun1, tun2...
    // 可以认为是 ioctl 将 tun0 设备与上面打开的 tun_fd(/dev/net/tun)连接起来了,
    // 对该 tun_fd 的读写, 就是对 tun0 设备的读写.
    //
    // 注意, ioctl 的 TUNSETIFF 标记要求 tun_fd 参数必须是 /dev/net/tun 的描述符,
    // 如果 tun_fd 只是一个普通文件的文件描述符, 则会报如下错误
    // Allocating interface: Inappropriate ioctl for device
    // 如果 tun_fd 是一个普通的字符设备文件, 则会报如下错误
    // Allocating interface: No such device or address
    // ...所以还是老老实实使用 /dev/net/tun 吧.
    err = ioctl(tun_fd, TUNSETIFF, (void *) &ifr);
    if (err < 0) {
        close(tun_fd);
        return err;
    }
    // 注意, 这里创建出来的 tun 设备是没有IP的, 状态也 DOWN 的.

    if (tun_fd < 0) {
        perror("Allocating interface");
        exit(1);
    }

    // ifr.ifr_name 为 tun0(或者 tun1, tun2...)
    printf("Open tun/tap device: %s for reading...\n", ifr.ifr_name);

    int nread;
    char buffer[1500];
    while (1) {
        nread = read(tun_fd, buffer, sizeof(buffer));
        if (nread < 0) {
            perror("Reading from interface");
            close(tun_fd);
            exit(1);
        }

        printf("Read %d bytes from tun/tap device\n", nread);
    }
    return 0;
}
