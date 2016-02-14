CasperNetInstallCreator
=======================

Releases including binaries can be found at https://github.com/jamf/CasperNetInstallCreator/releases
 

##Overview

The Casper NetInstall Image Creator was developed to optimize the imaging process and automate the creation of a NetBoot image.


Casper NetInstall Image Creator modifies an existing OS packages built with Composer or Disk Utility to NetInstall images by:
- Converting the image to a read/write format
- Removing components that are not essential to the NetInstall process
- Generating scripts that configure the image for the NetInstall boot process and launching Casper Imaging on startup
- Creating booter/kernel extension files according to the architecture on which the image was built. 
- Creating the NetBoot image property list file (configure the image index, enabled status, etc)
- Adding the Casper Imaging application to the image
- Creating the Casper Imaging preference file

##To create a NetInstall image:

 1. Select an OS package created with Composer, AutoDMG, or Disk Utility. This must be a DMG-style package with the .dmg file extension.

 2. Specify a name for the image.
This name will be listed under the NetBoot Service pane in Server Admin.

 3. Enter an image index. If you are not planning to host the image on multiple servers for load
balancing, select an index between 1-4095. If you are going host the image on multiple servers, select an index between 4096–65535.

 4. Select the Enabled checkbox to enable the NetInstall image immediately after it is created.

 5. Select the Default checkbox to use the NetInstall image as the default image on the server.
 
 6. Select the Compress checkbox to compress the NetInstall image.

 7. Click the Choose button and choose the version of Casper Imaging you want to include in the NetInstall image.  To ensure the best performance, choose the latest version of the application.

 8. Select the Create Casper Preference File checkbox to create a preference file for Casper Imaging. 
 
 This creates the following file to ensure that Casper Imaging connects to your JSS automatically when computers boot from the NetInstall image:
`~/Library/Preferences/com.jamfsoftware.jss.plist`

 9. Enter the URL of the JSS you'd like to use for imaging. 

 10. Click the Create button and choose the location to which you want to publish the NetBoot folder (NBI folder).
By default, the folder is published to the default share point location on Mac OS X Server:
`/Library/NetBoot/NetBootSP0/`

##Troubleshooting
If clients fail to boot when connected to the NetBoot server, verify NetBoot is started on the server and serving over the connection on which the clients are booting. Then, verify your image is enabled and set as the default image on the server.

If NetBoot was started prior to using this tool, you may need to stop the service and restart it for the server to recognize the recently created image.

If you are unable boot clients to NetBoot by holding down the N key during startup, try booting the client to a valid operating system. Then, navigate to **System Preferences** > **Startup Disk** and verify that the NetBoot server is displayed as an available startup disk. If the NetBoot server is not displayed as an available startup disk, there could be a firewall or the layer-3 device on the network may not be configured to pass Bootp packets to the NetBoot server.
This issue may occur if clients are booted in a subnet other than the one on which the NetBoot server resides. It can usually be resolved by creating an “IP Helper” address on the layer-3 device. For more information on this issue, refer to the following article from Apple:
http://support.apple.com/en-us/HT4187

If the NetBoot server is displayed as an available startup disk and the client starts to boot but doesn’t complete the process or kernel panics, press Command + V immediately after the globe begins to blink to NetBoot via verbose mode. This provides step-by-step feedback during the boot process.

If none of these resolutions are successful, check the NetBoot logs on the server through Server Admin using the NetBoot service.
