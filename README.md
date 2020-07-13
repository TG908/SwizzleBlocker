# SwizzleBlocker
🚷Proof of concept for a library that can intercept calls to `method_exchangeImplementations` and block them

⚠️ **This is in no way safe. Please don't ever use this in production code**

# Features

## Swizzle Blocker

![Screen Recording 2020-07-12 at 16 47 57](https://user-images.githubusercontent.com/7985149/87249899-17998e80-c462-11ea-80a7-c4c4ba66d0b9.gif)

## Swizzle Notification

<img src="https://user-images.githubusercontent.com/7985149/87261763-cddb9300-c4b7-11ea-9cc0-c6b555c3f06d.png" width="400"/>

# Installation

1. Download the project and build the frameworks
2. Drag the framework you want to use in your xcode project.
3. Select sign and embed for the framework
4. Build and run your app (make sure to use static linking for the frameworks you want to inspect)

# TODOs
- [x] Copy Paste Style Popup
- [ ] Hook more objc runtime functions related to swizzling

# Possible Uses
- Disable swizzling in the whole app
- Inspect the use of swizzling
- Decide to allow / disallow swizzling on a per case basis
