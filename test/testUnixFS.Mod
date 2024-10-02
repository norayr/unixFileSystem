MODULE testUnixFS;
IMPORT UnixFS, Out;

PROCEDURE test;
VAR
  fl: UnixFS.fileInfo;
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


END test;


BEGIN
 test;

END testUnixFS.


