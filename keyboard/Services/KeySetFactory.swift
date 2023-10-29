//
//  KeySetFactory.swift
//  ibepo
//  KomiKeyboard
//
//  Created by Steve Gigou on 2020-05-04.
//  Edited by Aleksei Ivanov on 2020-10-17
//  Copyright © 2020 Novesoft. All rights reserved.
//  Copyright © 2020 majbyr.com. All rights reserved.
//

final class KeySetFactory {
  
  func generate() -> KeySet {
    var rows = [Row]()
    rows.append(generateRow1())
    rows.append(generateRow2())
    rows.append(generateRow3())
    return KeySet(rows: rows)
  }
  
  private func generateRow1() -> Row {
    var row = Row()
      row.append(generateKey(for: KeyCharacterSet(
        "й", nil, ["й","1"], "1",
        secondaryShiftLetter: "[", ["[", "1","¹"])
      ))
    row.append(generateKey(for: KeyCharacterSet(
        "ц", nil, ["ц","2"], "2",
        secondaryShiftLetter: "]", ["]", "2","½","²"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "у", nil, ["ӱ", "у","3"], "3",
        secondaryShiftLetter: "{", ["{", "3","³"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "к", nil, ["к","4"], "4",
        secondaryShiftLetter: "}", ["}", "4","¼","¾"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "е", nil, ["ё","е","5"], "5",
        secondaryShiftLetter: "#", nil)
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "н", nil, ["ҥ", "н", "6"], "6",
        secondaryShiftLetter: "%", nil)
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "г", nil, ["г","7"], "7",
        secondaryShiftLetter: "^", nil)
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "ш", nil, ["щ","ш","8"], "8",
        secondaryShiftLetter: "*", nil)
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "щ", nil, ["ш","щ","9"], "9",
        secondaryShiftLetter: "+", nil)
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "з", nil, ["0", "з"], "0",
        secondaryShiftLetter: "=", nil)
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "х", nil, ["∞", "х"], "∞",
        secondaryShiftLetter: "'", nil)
    ))
    return row
  }
  
  private func generateRow2() -> Row {
    var row = Row()
      row.append(generateKey(for: KeyCharacterSet(
        "ф", nil, ["ф","—","-","_"], "-",
        secondaryShiftLetter: "_", ["_","-","—"])
      ))
    row.append(generateKey(for: KeyCharacterSet(
        "ы", nil, ["ы","/"], "/",
        secondaryShiftLetter: "\\", ["\\", "/","ы"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "в", nil, ["в",":"], ":",
        secondaryShiftLetter: "|", ["|", ":",";"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "а", nil, ["а",";"], ";",
        secondaryShiftLetter: "~", ["~", "°",";","%","‰"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "п", nil, ["п","("], "(",
        secondaryShiftLetter: "<", ["(", "<", "¢"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "р", nil, ["р",")"], ")",
        secondaryShiftLetter: ">", ["₽",")", ">", "£"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "о", nil, ["ӧ", "о", "№"], "№",
        secondaryShiftLetter: "€", ["€", "№","±"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "л", nil, ["л","₽"], "$",
        secondaryShiftLetter: "₽", ["₽", "$"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "д", nil, ["ј", "д"], "&",
        secondaryShiftLetter: "¥", ["≈","≠", "=","≥","&"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "ж", nil, ["@", "ж"], "@",
        secondaryShiftLetter: "•", ["©","™","®","@"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "э", nil, ["\"","·","э"], "\"",
        secondaryShiftLetter: "·", ["·","×","*", "\""])
    ))
    return row
  }
  
  private func generateRow3() -> Row {
    var row = Row()
    row.append(generateKey(for: KeyCharacterSet(
        "я", nil, ["я","❤️"], "❤️",
        secondaryShiftLetter: "❤️", ["❤️","🙏","👍"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "ч", nil, ["ч","😂"], "😂",
        secondaryShiftLetter: "😂", ["😂","💪","😭"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "с", nil, ["с",","], ",",
        secondaryShiftLetter: ",", [",",";"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "м", nil, ["м","!"], "!",
        secondaryShiftLetter: "!", ["!","¡"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "и", nil, ["і","и","?"], "?",
        secondaryShiftLetter: "?", ["?","÷"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "т", nil, ["т", "."], ".",
        secondaryShiftLetter: ".", ["…",".",":"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "ь", nil, ["ъ","ь","‘"], "‘",
        secondaryShiftLetter: "‘", [".", ";", "‘"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "б", nil, ["\"", "б"], "📲",
        secondaryShiftLetter: "📲", ["\"", "📲"])
    ))
    row.append(generateKey(for: KeyCharacterSet(
        "ю", nil, ["🚀", "ю"], "🚀",
        secondaryShiftLetter: "🚀", ["☎", "🚀"]
    )))
    return row
  }
      
    private func generateKey(for characterSet: KeyCharacterSet, alt: Key.State = .off) -> Key {
        Key(set: characterSet, alt: alt)
    }
  
}
