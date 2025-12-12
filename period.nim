## This program keeps track of different cyclic occasions, e.g. female period.
## Just add two or three calendar dates and try it yourself.

import algorithm, math, os, sequtils, stats
import strformat, strutils, sugar, tables, times

## basic consts & vars to work with
type Order = object
    comment: string
    f: (string) -> void

const
    datafile = getHomeDir() / ".nimble" / "period.dat"
    fstr = "dd-MM-yyyy"
    f = initTimeFormat fstr
    X = "▇"
    AVG_MONTH_LEN = 30.4375

let params = commandLineParams()
var dates: seq[DateTime] = @[]


## under-the-hood funcs
proc strDate(d: DateTime): string = d.format(f)
proc parseDate(s: string): Datetime = s.parse(f)

proc quitOn(i: int) =
    if dates.len <= i:
        echo "No data in " & datafile; quit()

proc save() =
    let texts = dates.map(strDate)
    if not dirExists datafile.parentDir:
        createDir datafile.parentDir
    datafile.writeFile( texts.join("\n") )
    echo "Saved!"

proc spans(dates: seq[DateTime]): seq[int] =
    collect newSeq:
        for i in 1 ..< dates.len:
            int inDays dates[i]-dates[i-1]

proc getAvg(): float = quitOn 1; dates.spans.mean


## ordinal funcs
var add = Order(
    comment: &"add a date in '{fstr}' format... or the word 'today'",
    f: proc(d: string = "today") =
        if d in ["today", ""]:
            dates.add(now())
        else:
            dates.add(parseDate d)
        sort dates; save()
)

var avg = Order(
    comment: "compute an average cycle length (float)",
    f: proc(_:string="") = quitOn 1; echo getAvg()
)

var draw = Order(
    comment: "draw a nice diagram",
    f: proc(_:string="") =
        quitOn 1
        for i,span in dates.spans:
            echo &"{dates[i].strDate} {X.repeat(span)} ({span})"
        let last = inDays now()-dates[^1]
        echo &"{dates[^1].strDate} {X.repeat(last)} ({last}...)"
)

var prev = Order(
    comment: "the latest known zero day",
    f: proc(_:string="") = quitOn 0; echo strDate dates[^1]
)

var next = Order(
    comment: "probable next zero day; type e.g. 'next 2' to jump over cycles",
    f: proc(q: string = "") =
        quitOn 1
        
        let qDigits = join q.filter(isDigit)
        let cycles = if qDigits == "": 1
            else: parseInt qDigits
        let l = dates[^1]

        echo strDate l + days toInt round (cycles.float * getAvg())
)

var remove = Order(
    comment: &"remove a date in '{fstr}' format... or the word 'today'",
    f: proc(d: string = "today") =
        let dd = if d in ["today", ""]: d
            else: strDate now()
        dates = dates.filter(x => x.strDate != dd)
        sort dates; save()
)

var length = Order(
    comment: "output how many months and how many cycles are recorded",
    f: proc(_:string="") =
        let timeInt = int inDays(dates[^1] - dates[0]).float / AVG_MONTH_LEN
        echo &"{timeInt} months, {dates.len} cycles"
)


## collecting all this into a table...
let orders: OrderedTable[string, Order] = toOrderedTable({
    "add": add,
    "avg": avg,
    "draw": draw,
    "length": length,
    "next": next,
    "prev": prev,
    "remove": remove
})

proc help() =
    for (k,v) in orders.pairs:
        echo k, ": ", v.comment


## quit if smth is wrong, else initialize the 'dates' table
if params.len == 0:
    echo "use 'period help' for getting detailed list of options"; quit()

let order = params[0]

if order == "help":
    help(); quit()

if order notin orders:
    echo "Wrong command. Type 'period help' to see all possible commands"; quit()

if fileExists(datafile):
    let splittedTexts = datafile.readFile.split("\n")
    dates = splittedTexts.map(parseDate)

let arg = if params.len > 1: params[1]
    else: ""
orders[order].f(arg)
