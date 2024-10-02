MODULE UnixFS;
IMPORT SYSTEM, UnixStat;

CONST
  dir* = 0; char* = 1; block* = 2; file* = 3; fifo* = 4;
  symlink* = 5; socket* = 6;

TYPE
   fileInfo* = RECORD;
     name* : ARRAY 256 OF CHAR;
     attr- : SET
     END;

  Status = ARRAY 512 OF SYSTEM.BYTE;

PROCEDURE -Aincludesysstat '#include <sys/stat.h>';
PROCEDURE -Aincludesystypes '#include <sys/types.h>';
(*
PROCEDURE -AinitStatus 'struct stat st';
*)
PROCEDURE -mkdir(VAR path: ARRAY OF CHAR): INTEGER
  "(int)mkdir(path, 0755)";

PROCEDURE mkDir*(path: ARRAY OF CHAR): BOOLEAN;
VAR res: INTEGER;
BEGIN
   res := mkdir(path);
   IF res = 0 THEN RETURN TRUE ELSE RETURN FALSE END
END mkDir;

PROCEDURE -statMode(VAR st: Status): LONGINT "((struct stat*)&st)->st_mode";


PROCEDURE -stat(VAR path : ARRAY OF CHAR; st: Status): INTEGER
"stat((const char*)path, (struct stat*)&st)";

PROCEDURE -isDir(mode: LONGINT): INTEGER
"S_ISDIR(mode)";

PROCEDURE -isChar(mode: LONGINT): INTEGER
"S_ISCHR(mode)";

PROCEDURE -isBlock(mode: LONGINT): INTEGER
"S_ISBLK(mode)";

PROCEDURE -isReg(mode: LONGINT): INTEGER
"S_ISREG(mode)";

PROCEDURE -isFIFO(mode: LONGINT): INTEGER
"S_ISFIFO(mode)";

PROCEDURE -isLnk(mode: LONGINT): INTEGER
"S_ISLNK(mode)";

PROCEDURE -isSock(mode: LONGINT): INTEGER
"S_ISSOCK(mode)";

PROCEDURE Exists*(VAR fl : fileInfo): BOOLEAN;
VAR
  i : INTEGER;
  st: Status;
  mode: LONGINT;
BEGIN
  fl.attr := {};
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*)
    mode := statMode(st);
    i := isDir(mode);
    IF i # 0 THEN fl.attr := fl.attr + {dir} END;
    i := isChar(mode);
    IF i # 0 THEN fl.attr := fl.attr + {char} END;
    i := isBlock(mode);
    IF i # 0 THEN fl.attr := fl.attr + {block} END;
    i := isReg(mode);
    IF i # 0 THEN fl.attr := fl.attr + {file} END;
    i := isFIFO(mode);
    IF i # 0 THEN fl.attr := fl.attr + {fifo} END;
    i := isLnk(mode);
    IF i # 0 THEN fl.attr := fl.attr + {symlink} END;
    i := isSock(mode);
    IF i # 0 THEN fl.attr := fl.attr + {socket} END;
    RETURN TRUE
  END;
END Exists;

PROCEDURE ExistsByName*(fileName : ARRAY OF CHAR): BOOLEAN;
VAR
  i : INTEGER;
  st: Status;
  fl: fileInfo;
  mode: LONGINT;
BEGIN
  fl.attr := {};
  COPY(fileName, fl.name);
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*)
    mode := statMode(st);
    i := isDir(mode);
    IF i # 0 THEN fl.attr := fl.attr + {dir} END;
    i := isChar(mode);
    IF i # 0 THEN fl.attr := fl.attr + {char} END;
    i := isBlock(mode);
    IF i # 0 THEN fl.attr := fl.attr + {block} END;
    i := isReg(mode);
    IF i # 0 THEN fl.attr := fl.attr + {file} END;
    i := isFIFO(mode);
    IF i # 0 THEN fl.attr := fl.attr + {fifo} END;
    i := isLnk(mode);
    IF i # 0 THEN fl.attr := fl.attr + {symlink} END;
    i := isSock(mode);
    IF i # 0 THEN fl.attr := fl.attr + {socket} END;
    RETURN TRUE
  END;
END ExistsByName;


END UnixFS.
