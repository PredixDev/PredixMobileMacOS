##Predix Mobile MacOS Container sample app

This project is the sample reference application for the Predix Mobile Container on the MacOS platform.

##Getting Started
It is assumed you already have a Predix Mobile cloud services installation, have installed the Predix Mobile command line tool, and have completed the steps in the following topics to publish your initial Predix Mobile webapp, define your Predix Mobile app, and import the sample data:

* [Get Started with the Mobile Service and Mobile SDK] (https://www.predix.io/docs#rae4EfJ6) 
* [Running the Predix Mobile Sample App] (https://www.predix.io/docs#EGUzWwcC)
* [Creating a Mobile Hello World Webapp] (https://www.predix.io/docs#DrBWuHkl) 

It is also assumed you're running on a Mac, with XCode version 7.3 installed.

## Download the Container and Start the App

* [Downloading the MacOS Predix Mobile App Container] (https://www.predix.io/docs#Z33mf56J)
* [Starting your MacOS Sample App] (https://www.predix.io/docs/?r=146467#jKRPb468)


## TroubleShooting:

### Enabling increased logging:

Logging by default is set at "Info" level. There are two more informative levels that can give you more information for debugging problems: Debug, and Trace.

### Enable debugging console:

To enable the debug console in the PredixMobileMacOS project run this command in Terminal:

    defaults write com.ge.PredixMobileMacOS WebKitDeveloperExtras -bool true

Then you can right-click or ctrl-click on the PredixMobileMacOS UI and select “Inspect Element” to bring up the debug console.

Note, if you change the bundle id of the project you need to use the correct bundle id in the command above. A more generic version of the command is: `defaults write <your bundle id> WebKitDeveloperExtras -bool true`

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


