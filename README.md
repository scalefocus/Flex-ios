Flex
===================
The library's goal is to store and facilitate the proccess of adding string assets to iOS projects by providing an easy to use interface for getting and updating strings from a hosted server. This allows you to manage the strings from the web admin panel and update them in the live product, without the need of recompiling and releasing a new version of the app.
The library also makes it easy to add a new translation to the app. Just add the new language strings in the admin panel and voilà - the users can already see and use the new language option.


The library is divided into two modules. One module is open to the outside world and the other one is hidden. The modules are: **Main Service** and **Update Service**.
The Job of the Main Service module is to provide easy to use functionality to get Strings for supported language.
The Job of the Update Service module is to update strings of current language on regular basis.

----------
Pod Installation
-------------

In order to integrate the pod, you'll have to add 'Flex' to your Podfle.

You can add the Flex pod in a familiar way:
```
pod 'Flexx'
```

Now run this from the directory where your project is.
```
pod install
```

```
import Flex
```
----------

**Library Integration:**

**Run Script:**
You will need to add a run script to your project. For your convenience, the script is included in the pod.

In your project - open Build Phases and add a new Run script with the following:
```
chmod +x ./Pods/Flexx/localizer_download.sh
././Pods/Flexx/localizer_download.sh APP_ID="APP_ID" SALT="SALT" DOMAINS="DOMAIN1,DOMAIN2,DOMAIN3" BASE_URL="BASE_URL"
```

The path to the script is specified as relative to the project root directory. If you want you can specity different path relative to the project root directory.

**SCRIPT EXPLANATION**:

***APP_ID*** - This is the identifier of the application. You have passed it as an argument in the Run Script.

***SALT*** - This is used for authentication for calls to the library. THIS IS THE SECRET USED WHEN CREATING THE APP IN THE CONSOLE. You have passed it as the <Secret> parameter in the Run Script.

***DOMAINS*** - These are all domain names. You have to passed them separated with comma(",") in the Run Script.

***BASE_URL*** - This is the strings provider service URL. You have to passed it as the <BASE_URL> parameter in the Run Script.

-------------

Library Interface
-------------

Flex contains several methods. Some of them are mandatory and others are optional. You should use those that fit the needs of your application. Flex is a Singleton instance.

**THIS IS MANDATORY**
```
Flex.shared.initialize(locale: Locale, enableLogging: Bool? = false, defaultReturn: DefaultReturnBehavior = .empty, completed: (() -> Swift.Void)? = nil)
```
Initialization of Flex. This method should be called as early as possible like in AppDelegate's method **didFinishLaunchingWithOptions:**
Parameters:

- locale: the current device Locale.
- enableLogging: bool that show if you want to have loggers for errors and messages
- defaultReturn: desired behavior when no key found
- completed: an optional callback when initialization process has finished.

The Flex instance **should be aware of the application's life cycle**.
So in the corresponding AppDelegate methods, call these Flex methods.

```
Flex.shared.didEnterBackground()
Flex.shared.willEnterForeground()
Flex.shared.willTerminate()
```

Optional Methods:

```
Flex.shared.getString(key: String)
```
Retreives value from a key-value collection

- key: domain name + key of the string
- returns: string value representing the value for the requested key
- example: getString(key: "domainName.stringKey")

```
Flex.shared.changeLocale(desiredLocale: Locale, changeCallback: Localizations.Flex.ChangeLocaleCallback? = default)
```
Function which change loaded translations with those for the passed as argument Locale. This is to force reading another locale file.
Parameters
- desiredLocale: Locale instance.
- changeCallback: callback when change of locale is completed no matter if it was successful

```
Flex.shared.getAvailableLocales(withCompletion completion: @escaping ([Language]) -> Void)
```

```
Flex.shared.getCurrentLocale() -> Locale
```

-----------

Usage
-------------

Here are some code snippets on how to use the library:

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	// Override point for customization after application launch.
	Flex.shared.initialize(locale: Locale.current, enableLogging: true, defaultReturn: Flex.DefaultReturnBehavior.empty, completed: {
		print("initialize callback")
	})
	// ... Other implementations
	return true
}

```
```
let text = Flex.shared.getString(key: "Domain.test_one")

```

```
let locale = someBoolean ? "en" : "bg"
Flex.shared.changeLocale(desiredLocale: Locale.init(identifier: locale), changeCallback: {[weak self] (success, locale) in
	print("Changed Locale was successful \(success) and current locale is \(locale)")
	let text = Flex.shared.getString(key: "Domain.test_one")
})

```

```
Flex.shared.getAvailableLocales { locales, args  in
    for language in locales {
        print("LANGUAGE: \(language.code), \(language.name)")
    }
    if let args = args {
        print("args: \(args)")
    }
}

```


