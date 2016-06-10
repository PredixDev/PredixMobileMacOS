##Predix Mobile MacOS Container sample app

This project is the sample reference application for the Predix Mobile Container on the MacOS platform.

##Getting Started
### Step 0 - Prerequisites
It is assumed you already have a Predix Mobile cloud services installation, have installed the Predix Mobile command line tool, and have followed the Getting Started examples for those repos to publish your initial Predix Mobile webapp, define your Predix Mobile app, and import the sample data. 

It is also assumed you're running on a Mac, with the latest version of XCode installed.

A basic understanding of how to use XCode is also assumed. For help with XCode consult Apple's documentation.

### Step 1 - Clone Repo

Clone the repo to your Mac

### Step 2 - Open the project file

Open the PredixMobileMacOS.xcodeproj file in XCode.

Written in Swift, this implementation is purposefully simple, and does not demonstrate every possible iteraction with the Predix Mobile SDK.

### Step 3 - Validate the Predix Mobile App

As one of the prerequistes, you defined a Predix Mobile App using the command line tool. The name and version of that pmapp is configured in the info.plist of the Predix Mobile Container.

In XCode, find the Info.plist file. The plist keys pmapp_name, and pmapp_version should match the values used in your app.json file you defined.

By default these settings are:

    pmapp_name: Sample1
    pmapp_version:  1.0

### Step 4 - Run the project

Run the project in XCode, the Predix Mobile Container should start.

The first time the PredixMobileMacOS container starts, it will popup an alert where settings can be entered. The intial server hostname setting for your Predix Mobile backend is required. If you do not remember your hostname, you can find is using the pm api command from the command line:

    :~ #] pm api
    info: API> https://123456.run.aws-usw02-pr.ice.predix.io

In the above example the server hostname is: 123456.run.aws-usw02-pr.ice.predix.io. This is what should be entered into the Server box of the preferences popup.

Once entered, this preferences popup will not automatically appear again, however like all MacOS apps, the preferences can be accessed via the menu.

Once the server hostname is entered and saved, you should be presented with the Predix login screen.


## TroubleShooting:

### Enabling increased logging:

Logging by default is set at "Info" level. There are two more informative levels that can give you more information for debugging problems: Debug, and Trace.

### I see a popup message: "Authentication failed" but I never saw the authentication page.

Reviewing the logs you will see various network error messages, and messages indicating you cannot connect to the backend.

First, ensure your Mac is online. Then, review the Server setting in the Settings app. It would appear your server host setting is not correct. Either a problem occured in Step 2, or the setting was changed so the system could never load the initial login page.

### I see a popup message: "Authentication failed" after I correctly entered my username and password

Reviewing the logs you may see a line like:

    Online authentication completed successfully

Then immediately afterwards:

     Error requesting user data:

And other networking related error messages.

In this case you successfully logged in, but then the system was unable to download your user information. Either due to a suddenly occuring network interuption, or some problem with the backend services.

### I see a popup message: "Unable to determine initial startup PredixMobile App"

This will occur if the pmapp_name, and pmapp_version configured in Step 4 is not found. Confirm that these settings match what was in your app.json file defined using the command line (pm tool) "define" command.

### Where is sad kitty?:

The sad kitty is the used in the iOS version of the container for error messages. This MacOS app uses a more utilitarian alert popup. While the sad kitty is fun and whimsical, the developers have taken this opportunaty to demonstrate the container's ability to control the serious error page UI. The Predix Mobile SDK is highly flexible and offers many possiblities. You're encouraged to make it your own.


