MODULE UnixFS;
IMPORT SYSTEM, UnixStat;

TYPE
   fileInfo* = RECORD;
     name* : ARRAY 256 OF CHAR;
     attr- : SET
     END;

  Status = UnixStat.Status;

PROCEDURE -Aincludesysstat '#include <sys/stat.h>';
PROCEDURE -Aincludesystypes '#include <sys/types.h>';

PROCEDURE -mkdir(VAR path: ARRAY OF CHAR): INTEGER
  "(int)mkdir(path, 0755)";

PROCEDURE mkDir*(path: ARRAY OF CHAR): BOOLEAN;
VAR res: INTEGER;
BEGIN
   res := mkdir(path);
   IF res = 0 THEN RETURN TRUE ELSE RETURN FALSE END
END mkDir;

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
BEGIN
  fl.attr := {};
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*)
    i := isDir(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.dir} END;
    i := isChar(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.char} END;
    i := isBlock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.block} END;
    i := isReg(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.file} END;
    i := isFIFO(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.fifo} END;
    i := isLnk(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.symlink} END;
    i := isSock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.socket} END;
    RETURN TRUE
  END;
END Exists;

PROCEDURE ExistsByName*(fileName : ARRAY OF CHAR): BOOLEAN;
VAR
  i : INTEGER;
  st: Status;
  fl: fileInfo;
BEGIN
  fl.attr := {};
  COPY(fileName, fl.name);
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*)
    i := isDir(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.dir} END;
    i := isChar(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.char} END;
    i := isBlock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.block} END;
    i := isReg(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.file} END;
    i := isFIFO(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.fifo} END;
    i := isLnk(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.symlink} END;
    i := isSock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {UnixStat.socket} END;
    RETURN TRUE
  END;
END ExistsByName;


END UnixFS.
