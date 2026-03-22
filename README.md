# TODO iOS App

Простой ToDo-лист на UIKit с хранением в CoreData, первым импортом задач из `https://dummyjson.com/todos`, поиском, CRUD-операциями в фоне и разбиением на VIPER-компоненты.

## Что внутри

- `TODOCore` - сущности, CoreData, сеть, preload первого запуска, interactor/presenter и unit-тесты.
- `TODOApp` - UIKit-интерфейс, сборка модулей и роутинг.
- `project.yml` - конфигурация для XcodeGen.
- `Package.swift` - позволяет прогнать unit-тесты ядра через `swift test`.

## Как запустить

1. Выберите полный Xcode:
   `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
2. Сгенерируйте проект:
   `xcodegen generate`
3. Откройте `TODO.xcodeproj` в Xcode и запустите схему `TODO`.

## Как прогнать тесты

- Быстрая проверка ядра без Xcode:
  `swift test`
- Полная iOS-проверка после генерации проекта:
  `xcodebuild test -scheme TODO -destination 'platform=iOS Simulator,name=iPhone 16'`


