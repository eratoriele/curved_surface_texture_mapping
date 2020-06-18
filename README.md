My current set-up:
XCode version 11.4.1
MacOS version 10.15.3 Beta
OpenCV version 4.1.0
Device used: Iphone 6S+, firmware 13.4.1

XCode should be installed beforehand.
Extract the zip file.
Open terminal and enter the file you just extracted.
Enter the command "pod init" to initialize cocoa pod.
Open the newly created Podfile in the project file.
If commented, uncomment the line what says "use_frameworks!"
Write "pod 'OpenCV'" below the "use_frameworks!" line.
Save and close the Podfile.
Enter "pod install" into the terminal, inside the same directory where you used "pod init"
Launch XCode and select the "Open another project" option.
Select the extracted file, and then choose the sceneopencv.xcworkspace (!!!NOT sceneopencv.xcodeproj!!!)
Connect your phone.
Select your phone from the menu on top left.
Run the program.
      A pop-up may appear informing you that the developer is not explicitly trusted by the device.
      On your phone, go to settings app and trust the developer.
      Run the program again.  



Contact: boragulerman@gmail.com
