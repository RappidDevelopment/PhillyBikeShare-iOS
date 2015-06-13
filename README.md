# Bike Philly

Bike Philly is a free iOS application that helps you locate the closest Indego docking station and how many bikes and open docks are available.

## Build Instructions

You'll need `Cocoapods` for most of our dependencies. [CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like [AFNetworking](https://github.com/AFNetworking/AFNetworking) in your projects. 
    
    $ gem install cocoapods
    
Download the source code 

    $ git clone https://github.com/RappidDevelopment/PhillyBikeShare-iOS.git
    $ cd PhillyBikeShare-iOS/
    
Now you'll need to build the dependencies.
    
    $ pod install
    
*Note*: **Don't open the `.xcodeproj`** file because we use Cocoapods, use the **`.xcworkspace`** file.

## Communication

- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, view our [waffle.io board](https://waffle.io/rappiddevelopment/phillybikeshare-ios) and/or submit a pull request.

## Third-party Libraries

This software additionally references or incorporates the following sources
of intellectual property, the license terms for which are set forth
in the sources themselves:

The following dependencies are bundled with the Ride Philly iOS application, but are under terms of a separate license:

* [AFNetworking](https://github.com/AFNetworking/AFNetworking) - A delightful iOS and OS X networking framework [![Build Status](https://travis-ci.org/AFNetworking/AFNetworking.svg)](https://travis-ci.org/AFNetworking/AFNetworking)

* [libextobjc](https://github.com/jspahrsummers/libextobjc) - A Cocoa library to extend the Objective-C programming language.

For a more complete list, check the [Podfile](https://github.com/RappidDevelopment/PhillyBikeShare-iOS/blob/develop/Podfile).

## Acknowledgements

This project is not directly affliated with the City of Philadelphia, Independence Blue Cross and the Indego Bike Share Program. More information about each can be found here:

* [City of Philadelphia](http://www.phila.gov/bikeshare/Pages/default.aspx)
* [Ride Indego] (http://www.rideindego.com)
* [Bike Share API v1.0](https://api.phila.gov/bike-share-stations/v1)

Other contributors include:

* [Rappid Development](http://rappiddevelopment.com/) - Coding and Development.
* [Chris Ventura Art](http://chrisventuraart.com) - Graphic Design

## License

Bike Philly: Philly Bike Share for iOS is released under the [DBAD] (http://www.dbad-license.org) license. See the DBAD LICENSE for details.
