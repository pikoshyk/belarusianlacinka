# Канвертар беларускай лацінкі | iOS Swift

> Гэты праект з'яўляецца перапісанай на Swift версія пракета [Lacinka](https://github.com/michaskruzelka/lacinka), першапачаткова створанага на PHP.

Belarusian Lacinka (Lacinica) converter

Бібліятэка для канвертавання тэкста на беларускай мове з кірыліцу ў лацінку і наадварот. Працуе з iOS, macOS, watchOS and tvOS, напісаная на Swift і даступная для ўстаноўкі праз Swift Package Manager.

Бібліятэка падтрымлівае канвертацыю:
- з Кірыліцы ў Лацінку
- з Лацінкі ў Кірыліцу
- у класічную
- у лацінку традыцыйную і геаграфічную

### Патрабаванні
- Xcode 12.x
- Swift 5.x

### Swift Package Manager
Каб уключыць BelarusianLacinka ў пакет Swift Package Manager, дадай яго ў `dependencies` у файле `Package.swift`. Напрыклад:
```
    dependencies: [
        .package(url: "https://github.com/belanghelp/belarusianlacinka.git", from: <version>),
    ]
```

### Ужыванне

```swift
import BelarusianLacinka
```

```swift
let originalText = "Толькі тады, народзе, зажывеш шчасліва, калі маскаля над табой не будзе! (с) Кастусь Каліноўскі"
let converter = BLConverter()
let convertedText = converter.convert(text: originalText, direction: .toLacin, version: .traditional, orthograpy: .classic)
print(convertedText)
```

Па пытаннях бібліятэкі можна звяртацца ў Twitter да [@pikoshyk](https://twitter.com/pikoshyk).
 

```
Праекту патрэбна дапамога: Dev, ML, PR, UI/UX, ...
```
