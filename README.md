# Virtual Tourist
> This app allows users specify travel locations around the world, and create virtual photo albums for each location. The locations and photo albums will be stored in Core Data.

## Features

* Travel Locations Map allows a user to drop pins with a touch and hold gesture
* Photo Album allows the user to download using Flickr API and edit an album for a location
* The user can update the photo album with a new set of images

## Requirements

- iOS 10.3+
- Xcode 8.3
- Cocoapods version 1.21 or later

## Installation

```
$ git clone https://github.com/enzoi/VirtualTourist.git <YourProjectName>
$ cd <YourProjectName>
$ pod install
$ open <YourProjectName>.xcworkspace
```

To add this app to a Firebase project, use the bundleID from the Xcode project. Download the generated GoogleService-Info.plist file, and copy it to the root directory of the sample you wish to run.
