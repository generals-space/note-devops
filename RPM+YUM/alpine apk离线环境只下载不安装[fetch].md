```log
/ # apk fetch ethtool -w
Downloading alpine-baselayout-3.4.3-r1
Downloading alpine-baselayout-data-3.4.3-r1
Downloading alpine-keys-2.4-r1
Downloading apk-tools-2.14.4-r0
Downloading busybox-1.36.1-r7
Downloading busybox-binsh-1.36.1-r7
Downloading ca-certificates-bundle-20240226-r0
Downloading hwdata-pci-0.370-r0
Downloading libc-utils-0.7.2-r5
Downloading libcrypto3-3.1.7-r0
Downloading libmnl-1.0.5-r1
Downloading libssl3-3.1.7-r0
Downloading musl-1.2.4-r2
Downloading musl-utils-1.2.4-r2
Downloading scanelf-1.3.7-r1
Downloading ssl_client-1.36.1-r7
Downloading zlib-1.2.13-r1
```

```log
~/apk # apk add ./* --no-network
WARNING: opening from cache https://dl-cdn.alpinelinux.org/alpine/v3.18/main: No such file or directory
WARNING: opening from cache https://dl-cdn.alpinelinux.org/alpine/v3.18/community: No such file or directory
(1/9) Upgrading busybox (1.36.1-r5 -> 1.36.1-r7)
Executing busybox-1.36.1-r7.post-upgrade
(2/9) Upgrading busybox-binsh (1.36.1-r5 -> 1.36.1-r7)
(3/9) Upgrading ca-certificates-bundle (20230506-r0 -> 20240226-r0)
(4/9) Upgrading libcrypto3 (3.1.4-r1 -> 3.1.7-r0)
(5/9) Upgrading libssl3 (3.1.4-r1 -> 3.1.7-r0)
(6/9) Upgrading ssl_client (1.36.1-r5 -> 1.36.1-r7)
(7/9) Upgrading apk-tools (2.14.0-r2 -> 2.14.4-r0)
(8/9) Installing libmnl (1.0.5-r1)
(9/9) Installing ethtool (6.2-r1)
Executing busybox-1.36.1-r7.trigger
OK: 9 MiB in 18 packages
```
