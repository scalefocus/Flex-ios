# Flexx

[![CI Status](https://img.shields.io/travis/nadezhdanikolova/PopupUpdate.svg?style=flat)](https://github.com/scalefocus/Flex-ios/)
[![Version](https://img.shields.io/cocoapods/v/PopupUpdate.svg?style=flat)](https://cocoapods.org/pods/Flexx)
[![License](https://img.shields.io/cocoapods/l/PopupUpdate.svg?style=flat)](https://cocoapods.org/pods/Flexx)
[![Platform](https://img.shields.io/cocoapods/p/PopupUpdate.svg?style=flat)](https://cocoapods.org/pods/Flexx)

The library's goal is to store and facilitate the proccess of adding string assets to iOS projects by providing an easy to use interface for getting and updating strings from a hosted server. This allows you to manage the strings from the web admin panel and update them in the live product, without the need of recompiling and releasing a new version of the app. The library also makes it easy to add a new translation to the app. Just add the new language strings in the admin panel and voilà - the users can already see and use the new language option.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

PopupUpdate is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Flexx'
```

and don't forget to install the pod by running the following command in the terminal from the directory of your project:

```
pod install
```

## Integration

You will need to add a run script to your project. For your convenience, the script is included in the pod.

In your project - open Build Phases and add a new Run script with the following:

```
chmod +x ./Pods/Flexx/Flexx/Classes/download_strings.sh
././Pods/Flexx/Flexx/Classes/download_strings.sh
```

>The first command chmod is for changing the permissions of script file. +x means that the file can be executed. For more commands see chmod documentation. The second line is the actual execution of the script. There the path to the script is specified as relative to the project root directory. If you want you can specity different path relative to the project root directory.


Your next step will be to create a .plist file with the name "Configuration".
After that fill the needed information. You can use the template from below.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AppId</key>
	<string>Your App ID Here</string>
	<key>BaseUrl</key>
	<string>Base Url Here</string>
	<key>Domains</key>
	<array>
		<string>Domain 1</string>
		<string>Domain 2</string>
	</array>
	<key>Secret</key>
	<string>Your App Secret Here</string>
</dict>
</plist>

```

AppId - identifier of the application.

BaseUrl - strings provider service url

Secret - used for authentication for calls to the library (This is the secret used when creating the app in the console)

Domains - these are all domain names

After that all you need is to import Flexx:

```swift
import Flexx
```

Flexx contains several methods. One of them is mandatory in order to use the library and others are optional.

Initialization of Flexx. This method should be called as early as possible like in AppDelegate's method **didFinishLaunchingWithOptions:**. This method is mandatory and should be called only once.

```swift
  let locale = Locale(identifier: "en-GB")
  Flexx.shared.initialize(locale: locale)
```

or you can use the extended init method:

```swift
  let locale = Locale(identifier: "en-GB")
  Flexx.shared.initialize(locale: locale,
                        	enableLogging: true,
                            defaultLoggingReturn: .key,
                            defaultUpdateInterval: 10,
                            completed: nil)
```

After the initialization you can get the string you need by calling this:

```swift
	let myString = Flexx.shared.getString(domain: "Domain-name-here", key: "word-key-here")
```

Here are the rest optional methods that you can use:

Get current locale:
```swift
Flexx.shared.getCurrentLocale()
```

Change current locale to desired locale:
```swift
Flexx.shared.changeLocale(desiredLocale: Locale(identifier: "en-GB"))
```

Get all available locales:
```swift
 Flexx.shared.getAvailableLocales { languages, error  in
            for language in languages {
                print("LANGUAGE: \(language.code), \(language.name)")
            }
            if let error = error {
                print("Error: \(error)")
            }
        }
```

## License

Flexx is available under the MIT license. See the LICENSE file for more info.
