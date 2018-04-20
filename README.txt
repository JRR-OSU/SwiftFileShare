SwiftFileShare(OSU CSE 3461) README
by Jon Reed

--- About ---

This project submission is an iPhone peer-to-peer file sharing application, written in Swift. This application makes use of Apple's Multipeer Connectivity Framework for peer-to-peer connections. All file data transmitted in this lab is end-to-end encrypted for security. 
In the project folder (called SwiftFileShare) you will find the Podfile (or dependency file)
as well as the project itself contained in the SwiftFileShare folder. The project is comprised of several .swift files,
a few of which define data objects used to represent users (and file cells) of the application, as well as other .swift files representing objects like the Multipeer Connectivity Manager
The other view controller swift files define and implement each UI view within the application. All the swift files are organized into folders which describe their purpose.

--- Running the application ---

To run and test this application, a Mac with Mac OS High Sierra and the newest version of Xcode are required.
Furthermore, an Apple developer license is required to deploy the application to an iOS device. To open the project in Xcode for evaluation,
double click on the SwiftFileShare.xcworkspace file in the project folder.

Since the grader for this project likely will not have this setup, I have made arrangements to demo the project to the instructor on Thursday, April 12th.

--- Using the application ---

Before using the app, please ensure that you have a working internet connection (via WIFI or cellular).

When the app starts, the user is prompted with a login or register selector. To create a user, select register and type in the display name, email, and password. Note that passwords must be at least 6 characters long. If some error occurs or the password is too short, alert messages are displayed via the UI to the user. If Firebase cannot register the user, the appropriate alert will be displayed. 
Once the user is created or logged in, the user is presented with a table view showing files by peer. This is a list that shows all files each user of the app has to transfer. To begin a file transfer, tap on the connects tab bar item. Then, select browse, and select the device with whom you want to share files with. Once the users are set as connected, select done and return to the file list. From there, a user can tap on another user's file (to send a request for that file) or the user can tap on one of their own files to send to that peer. Although the file browser is handled via Firebase realtime database, all connections are peer-to-peer and end to end encrypted. If the users are not connected with respective peers, they cannot send a file.

At any point during use, a user may tap on the "+" icon on the top right of the file view navigation controller. This will bring them to the brand new iOS 11 Document Browser which I have implemented for this lab. A user can see all the files that they can share, and they can even import files from elsewhere on the device that they wish to share. They can also tap on a file to preview or read it should the file type be compatible. 

To exit the document browser, I had to implement a workaround solution. iOS does not allow any view controller to be a parent view to the document browser, so as a workaround, pressing the plus icon in the Document browser will exit the user back to the file list. The typical behavior for this button is to create a file. 

--- Implementation details --- 

This application makes use of the Google Firebase Realtime Database and Authentication services and their respective APIs.
User accounts are created and logged into via implementation of Firebase authentication services API, and once each user is authenticated, their account is registered in a realtime database.
The GoogleService-Info.plist file contains application specific data such as the API key to connect to the database, and the application uses this file to make a connection and changes to the database. 

Note that each database is cached offline to the device. Because of this and the power of the Multipeer Connectivity framework, file transfers can happen completely offline, via an adhoc network between devices. 

The AppDelegate.swift file contains the initial Firebase API setup code, as well as functions which are called on application start and termination.

The Data Objects folder contains the implementation of the User object.

The Login folder contains the login screen implementation, (the same as in lab 1.)

The Multipeer Connectivity folder contains the implementation of the Multipeer Connectivity manager class. This class conforms to Apple's specifications and protocols for peer-to-peer transfers using this framework. Because this framework was built for iOS 7, I had issues with file writing compatibility on iOS 11. Due to this, I implemented a workaround to encapsulate all files in a Struct object. The struct is serialized before transmission, and decoded on receive back into the struct object. This way, all file details can be passed along with the file's binary structure.

The Table View folder within the Multipeer Connectivity folder contains the implementations of both table views. The first (file list) communicates with the realtime database to fetch user files, the second is for managing peer connections.

The File Browser folder contains the implementations of the Document File Browser view, as well as the preview controller for viewing files.  

The respective payload formats and Firebase connect functions for sending and observing messages are contained within their respective Swift source files. 

Each file is documented and should be fairly straightforward to comprehend thanks to the readability of Swift. Note that Swift is a weakly typed language. The 'var' keyword defines a mutable variable, while the 'let' keyword defines a constant. Type is not required in variable declarations, but is required when returning from a function or casting. 

--- Contact --- 

If you have any further questions about the source code (which is commented) or implementation and function, please feel free to email me at reed.1325@osu.edu.

Thank you for reading.