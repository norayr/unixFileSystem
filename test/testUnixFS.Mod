MODULE testUnixFS;
IMPORT UnixFS, Out;

PROCEDURE test;
VAR
  fl: UnixFS.fileInfo;
  fileList: UnixFS.list;
  i: LONGINT;
BEGIN
  Out.String("test"); Out.Ln;
  IF UnixFS.ExistsByName("GNUmakefile") THEN
    Out.String("makefile exists")
  ELSE
    Out.String("makefile not found")
  END;
  Out.Ln;

  COPY("GNUmakefile", fl.name);
  IF UnixFS.Exists(fl) THEN
    Out.String("makefile exists")
  ELSE
    Out.String("makefile not found")
  END;
  Out.Ln;

  IF UnixFS.mkDir("/tmp/aoe") THEN Out.String("/tmp/aoe created") ELSE Out.String("creating /tmp/aoe failed") END; Out.Ln;

  UnixFS.ListDir("/tmp", fileList);

  (* Process the fileList array *)
  FOR i := 0 TO LEN(fileList^)-1 DO
    IF UnixFS.dir IN fileList^[i].attr THEN
      Out.String("Dir: ")
    ELSIF UnixFS.file IN fileList^[i].attr THEN
      Out.String("File: ")
    ELSIF UnixFS.symlink IN fileList^[i].attr THEN
      Out.String("Symlink: ")
    ELSIF UnixFS.fifo IN fileList^[i].attr THEN
      Out.String("FIFO: ")
    ELSIF UnixFS.socket IN fileList^[i].attr THEN
      Out.String("Socket: ")
    ELSIF UnixFS.block IN fileList^[i].attr THEN
      Out.String("Block Device: ")
    ELSE
      Out.String("Other: ")
    END;
    Out.String(fileList^[i].name); Out.Ln;
  END;

END test;


BEGIN
 test;

END testUnixFS.


