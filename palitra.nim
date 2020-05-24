#[
    A simple desktop app enabling input of different Latin symbols I need daily (and nightly).
    It uses NiGui as its Nim GUI library.
    Also it provides a wonderful example of what the 'capture' command is needed for.
]#

import nigui, sequtils, strutils, sugar, unicode

let textlist = [
    "aàáȁȃâãäåæāăąɐɑɒʌçćĉċčɕďđðèéȅȇêëēĕėęěɛəɘɜ",
    "ɸĝğġģɢɣĥħɦìíȉȋîïĩīĭįıɨɪĵʝɟķĺļľłʎʟñńņňŋɲɴ",
    "òóȍȏôõöøōŏőœȯɵŕŗřɹɾʀʁßśŝşšșʂʃťþθ",
    "ùúȕȗûüũūŭůűųʉʊʋʍɯɰχýÿŷɥʏźżžʐʑʒ"
]
var texts = textlist.join.toRunes # seq of unicode symbols we want to be able to input

proc captureAndClick(i: int, but: Button, area: TextArea) =
    # when creating or modifying a button, we teach it to add a symbol to the text area
    capture i: # this thing gets value of i inside of the block. otherwise the program doesn't work
        but.onClick = proc(event: ClickEvent) = area.addText($texts[i])

proc toggleCase(buttons: seq[Button], textPlace: TextArea, toggleBut: Button) =
    # by this we modify functioning of all the buttons, including the toggling one
    if texts[0].isUpper:
        texts = texts.map(toLower)
        toggleBut.text = "lower"
    else:
        texts = texts.map(toUpper)
        toggleBut.text = "UPPER"
    for i, but in buttons:
        captureAndClick(i, but, textPlace)

app.init()

# create window and container for our elements
var window = newWindow("Symbol Palette")
window.width = 570.scaleToDpi
window.height = 500.scaleToDpi
var container = newContainer()
window.add(container)

# create buttons and add them to the container
var butSeq = texts.map(x => newButton($x))
var countH = 0
var countW = 0
for but in butSeq:
    container.add(but)
    but.x = countW * 40
    but.y = countH * 32
    if countW == 13:
        countW = 0
        countH += 1
    else:
        countW += 1

if countW > 0:
    countW = 0
    countH += 1

# create case-toggling button and add it to the container
var toggleButton = newButton("lower")
container.add(toggleButton)
toggleButton.x = 0
toggleButton.y = countH * 32
toggleButton.width = 70
countH += 1

# create text area and add it to the container
var textArea = newTextArea()
container.add(textArea)
textArea.x = 0
textArea.y = countH * 32
textArea.width = 560
textArea.height = 100

# add onclick for toggling button
toggleButton.onClick = proc(event: ClickEvent) = toggleCase(butSeq, textArea, toggleButton)

# add onclick for all buttons
for i, but in butSeq:
    captureAndClick(i, but, textArea)

window.show()
app.run()
