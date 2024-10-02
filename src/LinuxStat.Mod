MODULE UnixStat;

CONST
  dir* = 0; char* = 1; block* = 2; file* = 3; fifo* = 4;
  symlink* = 5; socket* = 6;

TYPE

(* https://github.com/vishaps/voc/blob/4bebc891a4d0d1184d74134908bdc1a91e3ad5be/src/lib/system/freebsd/clang/x86_64/Unix.Mod
from output of cpp /usr/include/sys/stat.h
struct stat {
 __dev_t st_dev;
 ino_t st_ino;
 mode_t st_mode;
 nlink_t st_nlink;
 uid_t st_uid;
 gid_t st_gid;
 __dev_t st_rdev;
 struct timespec st_atim;
 struct timespec st_mtim;
 struct timespec st_ctim;
 off_t st_size;
 blkcnt_t st_blocks;
 blksize_t st_blksize;
 fflags_t st_flags;
 __uint32_t st_gen;
 __int32_t st_lspare;
 struct timespec st_birthtim;
# 148 "/usr/include/sys/stat.h"
 unsigned int :(8 / 2) * (16 - (int)sizeof(struct timespec));
 unsigned int :(8 / 2) * (16 - (int)sizeof(struct timespec));
};
sizes on freebsd 64 bit
short int 2
int 4
long 8
long int 8
size_t 8
dev_t 4
ino_t 4
mode_t 2
nlink_t 2
uid_t 4
gid_t 4
off_t 8
blksize_t 4
blkcnt_t 8
time_t 8
fflags_t  4
__uint32_t  4
__int32_t  4
*)

(* this was old info. now it's like this:

size of stat is 224
size of s.st_dev is 8
size of s.st_ino is 8
size of s.st_nlink is 8
size of s.st_mode is 2
size of s.st_padding0 is 2
size of s.st_uid is 4
size of s.st_gid is 4
size of s.st_padding1 is 4
size of s.rdev is 8
size of s.st_atim is 16
size of s.st_mtim is 16
size of s.st_ctim is 16
size of s.st_birthtim is 16
size of s.st_size is 8
size of s.st_blocks is 8
size of s.st_blksize is 4
size of s.st_flags is 4
size of s.st_gen is 8
size of s.st_spare is 80
*)

  Status* = RECORD (* struct stat *)
    dev* : HUGEINT; (* dev_t 8 *)
    ino* : HUGEINT; (* ino 8 *)
    nlink* : HUGEINT;
    mode* : LONGINT;
    uid*, gid*: LONGINT;
    pad0* : LONGINT;
    rdev* : HUGEINT;
    size* : HUGEINT;
    blksize* : HUGEINT;
    blocks* : HUGEINT;
    atime* : HUGEINT;
    atimences* : HUGEINT;
    mtime* : HUGEINT;
    mtimensec* : HUGEINT;
    ctime* : HUGEINT;
    ctimensec* : HUGEINT;
    unused0*, unused1*, unused2*: HUGEINT;
    END;

END UnixStat.

