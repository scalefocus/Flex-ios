fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### deploy_crashlytics
```
fastlane deploy_crashlytics
```
Submit a new build to Crashlytics

This action does the following:



- Clear derived data

- Turn off automatic signing

- Increment the build number

- Change the bundle id to appropriate for in house provisioning profile

- Download or create certificates

- Download or create provisioning profile

- Switching to the correct team

- Updating provisioning profile with the one from sigh

- Build and sign the app

- Upload the ipa file to crashlytics

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
