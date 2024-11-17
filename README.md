# AnalyticsManager
`AnalyticsManager` is a lightweight and flexible Swift framework designed to integrate **Amplitude** analytics events into iOS applications. With an intuitive API and modular structure, the framework simplifies sending analytics events to **Amplitude**, allowing developers to focus on creating exceptional user experiences.

## Features
- **Easy Integration with Amplitude**: Easily set up the framework to send events to **Amplitude**.
- **Modular Structure**: Customize the framework to your needs by adding or removing modules for different analytics services.
- **Intuitive API**: A simple-to-use API for sending events to **Amplitude**.

## Installation

### Swift Package Manager (SPM)
1. In Xcode, go to `File`, open `Add Packages`
2. Insert the following URL: https://github.com/anastasiia1210/AnalyticsManager.git

### CocoaPods
1. Add `AnalyticsManagerFramework` to your `Podfile`:

```ruby
pod 'AnalyticsManagerFramework', '~> 0.0.1'
```
2. Run the following command in your terminal to install the dependency:
```pod install```

## Usage
1. Configuring the Framework
To start tracking events, configure the framework with your API key when the app launches. Add the following code to your app initialization:

```swift
AnalyticsManager.manage.configure(apiKey: "api_key")
```
2. Logging Custom Events
Log specific events throughout your application.
```swift
AnalyticsManager.manage.logEvent(
    userId: "user_12345",
    eventType: "subscribe",
    eventProperties: ["subscription_plan": "premium"]
)
```
3. Tracking Screen Navigation
Monitor user navigation between screens using the logScreenNavigation method:
```swift
AnalyticsManager.manage.logScreenNavigation(
    userId: "user_12345",
    fromScreen: "HomeScreen",
    toScreen: "DetailsScreen",
    fields: [.all]
)
```
### Additional Methods

This framework includes a variety of other methods for logging events, managing user sessions, and configuring analytics. You can explore the full list of methods and their usage in the framework's documentation, which is included within the codebase. 

To access the documentation, simply:

1. Open the framework in Xcode.
2. Use **Quick Help** (⌥ + Click on a method or class) to view detailed explanations and examples directly in the editor.

### Fields Description

The `fields` parameter in the AnalyticsManager API allows you to include additional metadata about the user's environment or app state when logging events. Below are the supported values and their meanings:

| **Field**       | **Description**                                  |
|------------------|-------------------------------------------------|
| `platform`       | The platform on which the app is running (e.g., iOS). |
| `country`        | The user's country based on locale or IP.       |
| `language`       | The language set on the user's device.          |
| `deviceType`     | The type of device (e.g., iPhone 12).        |
| `appVersion`     | The current version of the app.                 |
| `osName`         | The operating system name (e.g., iOS, macOS).   |
| `osVersion`      | The operating system version (e.g., 16.4).      |
| `all`            | Includes all the above fields.                  |
