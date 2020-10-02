#[
    Program written for cataloging files, originally for Windows,
    but when using os.DirSep (system-dependent dir separator sign) it becomes universal.

    Just put it into a directory and run it. The resulting catalog is in csv format.

    Originally written for a friend a few years ago in Python.
    Rewritten in Nim to enable usage without preinstalled Python
    and also to exercise my Nim skills a bit.
]#

import math, os, regex, strformat, strutils, times

proc decipher(file: string): string =
    const 
        ceilingNumber = 700_000 # bytes
        oneGB = 1024^3 # bytes
    let 
        splittedPath = file.splitPath
        filename = splittedPath.tail.replace(re"^[\!\+\-]+\s", "")
        filepath = splittedPath.head
        #[
            filename column goes before path column in our csv.
            replace() is used to delete signs my friend uses to mark unread,
            already read or somehow important files.
        ]#

        time = file.getLastModificationTime.local.format("yyyy'.'MM'.'dd")

        filesize = file.getFileSize + ceilingNumber
        gigs = "{formatFloat(filesize.float / oneGB.float, ffDecimal, 3)} GB".fmt
        #[
            file size in GB plus a little bit of forced ceiling.
            probably you will find a better way.
            it is possible to sort by size in the resulting csv,
            as well as by other data!
        ]#

    return "\"{filename}\",\"{filepath}\",\"{time}\",\"{gigs}\"\n".fmt

var text = "\"NAME\",\"CATALOG\",\"DATE\",\"SIZE\"\n"

for obj in absolutePath("").walkDirRec:
    text &= decipher(obj)

let outputFile = absolutePath("").split(DirSep)[^1] & ".csv"
# last element of the splitted abspath: 'work.csv' for '/home/user/work'
writeFile(outputFile, text)
