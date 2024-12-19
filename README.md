# Readme

## Introduction
ScribbleDemo is a very simple drawing application. This sample code is meant to demonstrate how to retrieve all of the Tablet information using the Appkit framework (Cocoa API).

To run these applications, a Wacom tablet driver must be installed and a ScribbleDemo-enabled device must be attached. All Wacom tablets supported by the Wacom driver are supported by this API. Get the driver that supports your device at: https://www.wacom.com/support/product-support/drivers.


## Application Details
The application uses the functions described in the [Driver Request Interface - Reference](https://developer-docs.wacom.com/docs/icbt/macos/dri/dri-reference/)
 documentation to communicate with the tablet driver. Data from the tablet arrives in standard Cocoa NSEvent's. If the driver is not functioning or is not installed, you will still be able to draw in ScribbleDemo with the mouse or other pointing device but you will not have pressure information from the Wacom tablet.

You can download the ScribbleDemo sample code and view the inline comments to find out detailed information about the sample code itself.

## See Also
The Driver Request Interface developer documentation has complete API details:

[Driver Request Interface - Basics](https://developer-docs.wacom.com/docs/icbt/macos/dri/dri-basics/)

[Driver Request Interface - Reference](https://developer-docs.wacom.com/docs/icbt/macos/dri/dri-reference/)

[Driver Request Interface - FAQs](https://developer-support.wacom.com/hc/en-us/articles/12845119756055-Driver-Request-Interface)

## Where To Get Help
If you have questions about this demo please visit our support page: https://developer.wacom.com/developer-dashboard/support. 

## License
This sample code is licensed under the MIT License: https://choosealicense.com/licenses/mit/
