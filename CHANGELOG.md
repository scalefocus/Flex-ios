### Changelog

All notable changes to this project will be documented in this file. Dates are displayed in UTC.

####   Changes between v2.7.0 and 3.0.0.

- The file localizer_download.sh is renamed to download_strings.sh. The script does not need appId, key, baseUrl and domains as parameters. All this parameters are taken from a Configuration.plist file, which should be created in order to use the library. Check README.md to setup correctly.
- New optional parameter is added to the initializer of the library - defaultUpdateInterval. This is the default time interval in miliseconds.
- The function for getting a string( func getString()) is changed. Now it requires two parameters - first one is the domain name and the second one is the word key.