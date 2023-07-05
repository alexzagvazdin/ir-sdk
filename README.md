# IR SDK 
`v0.1.0`

<img src="https://user-images.githubusercontent.com/9215552/209924488-52add5fd-00a1-4468-a933-cd0cb39addfc.png" width="500">

## Architecture

<img src="https://user-images.githubusercontent.com/9215552/209679382-11f1a63f-f51f-4dbf-89d9-20b89d6102f8.png" width="500">

## Installation

### Manual

1. Download a copy or clone the repository and make sure you checkout the latest tagged version.
2. Embed the IRSDK.xcframework in your own project.

### Swift Package Manager

1. Go to XCode project settings and add new Swift Package dependency.
2. Enter repository URL: https://github.com/gospotcheck/ir-sdk/
3. Provide your Github account username and [personal token](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
4. Specify the IR SDK version you want to use.

### NSCameraUsageDescription

The IR SDK uses device camera for taking pictures, hence your app's Info.plist file should include `NSCameraUsageDescription` property with the user-visible message. For reference, see [NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription).

## Initialization

The IR SDK must be initialized before the photo grid functionalities are used. Initialize the IR SDK, by calling `IRSDK.initialize()` function. It is recommended to call this function in the `AppDelegate` implementation as soon as the app was started.

```swift
try await IRSDK.initialize()
```
or
```swift
IRSDK.initialize { result in ... }
```

> IMPORTANT: Prior to calling the `initialize` method, implement the Auth Delegate and set the `IRSDK.authDelegate` property as described below. This will allow the SDK to handle expired auth tokens and make sure the users always stay authenticated.

## Authentication

### Authenticate

Authentication usually requires implementation on the server side in addition to implementation on mobile. In a typical flow, the server code will authenticate with the IR backend and request the app token that should later be used in mobile code. App tokens are unique and new token should be requested for each mobile device that will be connecting to the IR SDK. Token do expire new app tokens need to be requested by the server whenver an old token expires. Please see the Auth Delegate section below for more details. 

Once the app token has been obtained from the server, to authenticate and authorize the device for further usage, pass an app token received from IR backend to the SDK:

```swift
try await IRSDK.authenticate(with: appToken)
```
or
```swift
IRSDK.authenticate(with: appToken) { result in ... }
```
It is recommended to call this function after successful user login. Photo upload functionality would not work without authentication and authorization. 

### Deauthenticate

When user logs out from the app, make sure to deauthenticate the IR SDK.

```swift
IRSDK.deauthenticate()
```

### Auth Delegate

Authorization of the device may expire if the SDK will not be re-authenticated. To handle token expiration, implement the `AuthDelegate` protocol:

```swift
func didRequestNewAppToken() {
  // Fetch new app token and call authenticate(with:) again.
}
```
and set `IRSDK` delegate property:
```swift
IRSDK.authDelegate = self
```
Always set `authDelegate` before the IR SDK initialization. During initialization, the IR SDK calls `didRequestNewAppToken` delegate method if necessary. When app token expires and `didRequestNewAppToken` is called, fetch new app token from backend and authenticate the IR SDK again. 

### Errors

The IR SDK may throw followinig errors related to authentication and authorization of a device:
- `AuthError.cannotAuthenticate` - when the IR SDK cannot authenticate using received app token.
- `AuthError.unknown` - which is an envelope for any unexpected errors inside the IR SDK.

## Photo Grid

### User Interface

The IR SDK provides photo capture interface called Photo Grid. Photo Grid UI helps users take photos of store displays, arranges them in a grid structure and handles photo upload. To open photo grid from the IR SDK, call `showPhotoGrid(from:sceneType:metadata:delegate:)` from any `UIViewController`:

```swift
try IRSDK.showPhotoGrid(from: viewController, sceneType: sceneType, metadata: metadata, delegate: photoGridDelegate)
```
where:
- `viewController` is any `UIViewController` of your app.
- `sceneType` is a string that defines what kind of scene user is trying to capture. The following scene types are supported for testing:
    - `test-cooler` for pictures of coolers (a sequence of pictures captured vertically)
    - `test-shelf` for pictures of horizontal shelves (a sequence of pictures captured both horizontally and vertically). 
- `metadata` is a `[String : Codable]` structure that holds all necessary information that should be attached to the photo grid. Those metadata will be returned along with the tagging results by the IR backend. Metadata should be used for any information you would to have associated with the photo grid. Examples may include a visit ID, store ID, name, or location, etc. 
- `photoGridDelegate` is a `PhotoGridDelegate` implementation that reacts to photo grid creation and finish events. 

### Photo Grid Delegate

To receive a photo grid notifications, implement `PhotoGridDelegate` protocol:

```swift
extension MyViewController: PhotoGridDelegate {
  
  func photoGridDidCreate(photoGridID: String) {}
  
  func photoGridDidFinish() {}
}
```

- `photoGridDidCreate(photoGridID:)` is called everytime the user taps "Finish" or "Next Photo Grid" button in the Photo Grid UI. `photoGridID` is a unique identifier of newly created photo grid. This identifier is used as a grid reference when sending tagging results from the IR backend.
- `photoGridDidFinish()` is called after when the user taps "X" or "Finish" button. 

### Submit photo grid

To submit a photo grid for processing, call `IRSDK.submitPhotoGrid(id:)` using photo grid ID that was returned in the `photoGridDidCreate(photoGridID:)` delegate method.

```swift
try await IRSDK.submitPhotoGrid(id: photoGridID)
```
or
```swift
IRSDK.submitPhotoGrid(id: photoGridID) { result in ... }
```

Each photo grid created by the IR SDK must be submitted or deleted.

### Delete photo grid

Any photo grid that was not submitted, can be deleted by calling `IRSDK.deletePhotoGrid(id:)`:
```swift
try await IRSDK.deletePhotoGrid(id: photoGridID)
```
or
```swift
IRSDK.deletePhotoGrid(id: photoGridID) { result in ... }
```

### Errors

The IR SDK may throw followinig errors related to PhotoGrid functionalities:
- `PhotoGridError.photoGridNotFound` - when the IR SDK receives non-existing or already submitted photo grid.
- `PhotoGridError.sceneTypeNotFound` - when the IR SDK receives invalid scene type.
- `PhotoGridErorr.unknown` - which is an envelope for any unexpected errors inside the IR SDK.

# IR SDK Sample

<img src="https://user-images.githubusercontent.com/9215552/209809454-57b77833-950c-40e9-9a22-9db0fe8a0ad1.png" width="800">

Open `IRSDKSample` folder with XCode and run it on your device. 

> **Note**
> The IR SDK Sample works on simulator, but you will not be able to take photos.
