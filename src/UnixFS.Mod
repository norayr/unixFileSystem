MODULE UnixFS;
IMPORT SYSTEM, Out;

TYPE
   fileInfo* = RECORD;
     name* : ARRAY 256 OF CHAR;
     attr- : SET
     END;

   list* = POINTER TO ARRAY OF fileInfo;

   Status = ARRAY 512 OF SYSTEM.BYTE;

VAR
  dir-,char-, block-, file-, fifo-, symlink-, socket- : INTEGER;
  dirEl-, charEl-, blockEl-, fileEl-, fifoEl-, symlinkEl-, socketEl-: SET;
PROCEDURE -Aincludesysstat '#include <sys/stat.h>';
PROCEDURE -Aincludesystypes '#include <sys/types.h>';
PROCEDURE -Aincludedirent '#include <dirent.h>';  (* For directory handling *)

PROCEDURE -opendir(path: ARRAY OF CHAR): SYSTEM.PTR
  "opendir((const char*)path)";

PROCEDURE -readdir(dir: SYSTEM.PTR): SYSTEM.PTR
  "readdir((DIR*)dir)";

PROCEDURE -closedir(dir: SYSTEM.PTR): INTEGER
  "closedir((DIR*)dir)";

PROCEDURE -direntName(d: SYSTEM.PTR): SYSTEM.PTR
  "((struct dirent*)d)->d_name";


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

PROCEDURE CopyCStringToOberon*(cStr: SYSTEM.PTR; VAR oStr: ARRAY OF CHAR);
VAR
  i: INTEGER;
  c: CHAR;
BEGIN
  i := 0;
  REPEAT
    SYSTEM.GET(SYSTEM.VAL(SYSTEM.ADDRESS, cStr) + i, c);  (* Proper address handling *)
    IF c # 0X THEN
      oStr[i] := c;
      INC(i);
    END;
  UNTIL (c = 0X) OR (i >= LEN(oStr));  (* Ensure we don't exceed the array bounds *)
  oStr[i] := 0X;  (* Null-terminate the Oberon string *)
END CopyCStringToOberon;

PROCEDURE CountFiles*(path: ARRAY OF CHAR): INTEGER;
VAR
  dir, entry: SYSTEM.PTR;
  count, i: INTEGER;
BEGIN
  count := 0;
  dir := opendir(path);
  IF dir # NIL THEN
    REPEAT
      entry := readdir(dir);
      IF entry # NIL THEN INC(count) END;
    UNTIL entry = NIL;
    i := closedir(dir);
  ELSE
    Out.String("Unable to open directory: "); Out.String(path); Out.Ln;
  END;
  RETURN count;
END CountFiles;

PROCEDURE ListDir*(path: ARRAY OF CHAR; VAR fileList: list);
VAR
  dir, entry: SYSTEM.PTR;
  entryName: ARRAY 256 OF CHAR;
  i, fileCount: INTEGER;
  st: Status;
  mode: LONGINT;
  j: INTEGER;
BEGIN
  (* Count the number of files/directories *)
  fileCount := CountFiles(path);

  (* Allocate the array for fileInfo *)
  NEW(fileList, fileCount);

  (* Open directory again to populate fileInfo *)
  dir := opendir(path);
  IF dir # NIL THEN
    i := 0;
    REPEAT
      entry := readdir(dir);
      IF entry # NIL THEN
        (* Use the helper procedure to copy the entry name *)
        CopyCStringToOberon(direntName(entry), entryName);

        (* Copy the file name to fileInfo *)
        COPY(entryName, fileList^[i].name);

        (* Get the file attributes using stat *)
        IF stat(fileList^[i].name, st) = 0 THEN
          fileList^[i].attr := {};  (* Reset attributes *)

          mode := statMode(st);  (* Fetch mode once *)
          (* Identify if it's a directory or file and assign attributes accordingly *)

          IF isDir(mode) # 0 THEN
            fileList^[i].attr := fileList^[i].attr + dirEl;
            (*Out.String("Directory: ");*)  (* Output more descriptive information *)
          ELSIF isReg(mode) # 0 THEN
            fileList^[i].attr := fileList^[i].attr + fileEl;
            (*Out.String("File: ");*)
          (*
          ELSE
            Out.String("Other (special): ");
          *)
          END;
        END;

        (* Print fileInfo for debugging *)
        (*
        Out.String(fileList^[i].name); Out.Ln;
        *)

        INC(i);  (* Move to the next fileInfo entry *)
      END;
    UNTIL entry = NIL;
    j := closedir(dir);
  ELSE
    Out.String("Unable to open directory: "); Out.String(path); Out.Ln;
  END;
END ListDir;

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

BEGIN
  dir:= 0; char:= 1; block:= 2; file:= 3; fifo:= 4;
  symlink:= 5; socket:= 6;
  dirEl := {0}; charEl := {1}; blockEl := {2}; fileEl := {3}; fifoEl := {4};
  symlinkEl := {5}; socketEl := {6};
END UnixFS.
