import Foundation
import CoreLocation
import UIKit

/// A class for managing analytics events, designed specifically for integration with Amplitude.
/// This class allows logging user events, clicks, screen navigations, and more,
/// providing a seamless way to track user behavior in an application.
///
/// `AnalyticsManager` uses Amplitude's API and supports additional metadata fields like platform, device type,
/// country, language, and app version.
public final class AnalyticsManager {
    
    /// Singleton instance of `AnalyticsManager`.
    @MainActor public static let manage = AnalyticsManager()
    private var apiKey: String?
    private var provider: AnalyticsProvider = AnalyticsProvider()
    
    private init() {}
    
    /// Configures the `AnalyticsManager` with an API key.
    /// - Parameter apiKey: The Amplitude API key for the analytics provider.
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Enum representing additional fields for event logging.
    public enum AnalyticsField {
        case platform, country, language, deviceType, appVersion, osName, osVersion, all
        
        /// Returns the key associated with the field.
        var key: String {
            switch self {
            case .platform: return "platform"
            case .country: return "country"
            case .language: return "language"
            case .deviceType: return "device_type"
            case .appVersion: return "app_version"
            case .osName: return "os_name"
            case .osVersion: return "os_version"
            case .all: return "all"
            }
        }
        
        /// Returns all available fields.
        static func allFields() -> [AnalyticsField] {
            return [.platform, .country, .language, .deviceType, .appVersion, .osName, .osVersion]
        }
    }
    
    /// Logs a general event with specified parameters.
    /// - Parameters:
    ///   - userId: The ID of the user triggering the event.
    ///   - eventType: The type of the event.
    ///   - screen: (Optional) The screen where the event occurred.
    ///   - sessionId: (Optional) The session ID.
    ///   - userProperties: (Optional) User-specific properties.
    ///   - eventProperties: (Optional) Event-specific properties.
    ///   - fields: Additional fields to include in the event.
    @MainActor public func logEvent(
        userId: String,
        eventType: String,
        screen: String? = nil,
        sessionId: String? = nil,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        
        var event: [String: Any] = [
            "user_id": userId,
            "event_type": eventType
        ]
        
        var fields = fields
        if fields.contains(.all) {
            fields = AnalyticsField.allFields()
        }
        
        for field in fields {
            switch field {
            case .platform:
                event["platform"] = getPlatform()
            case .country:
                event["country"] = getCountryName()
            case .language:
                event["language"] = getLanguageName()
            case .deviceType:
                event["device_type"] = UIDevice.modelName
            case .appVersion:
                event["app_version"] = getAppVersion()
            case .osName:
                event["os_name"] = UIDevice.current.systemName
            case .osVersion:
                event["os_version"] = UIDevice.current.systemVersion
            case .all:
                break
            }
        }
        
        var allEventProperties = eventProperties ?? [:]
        
        if let screen = screen {
            allEventProperties["screen"] = screen
        }
        
        if let sessionId = sessionId {
            event["session_id"] = sessionId
        }
        
        if let userProperties = userProperties {
            event["user_properties"] = userProperties
        }
        
        if !allEventProperties.isEmpty {
            event["event_properties"] = allEventProperties
        }
        
        let payload: [String: Any] = [
            "api_key": apiKey,
            "events": [event]
        ]
        
        provider.sendEvent(payload: payload) { result in
            switch result {
            case .success:
                print("Event sent successfully")
            case .failure(let error):
                print("Failed to send event: \(error.localizedDescription)")
            }
        }
    }
    
    /// Logs a click event in the application.
    /// This method is a specialized version of `logEvent` for tracking user interactions
    /// with UI elements such as buttons, links, or other actionable components.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user who triggered the click event.
    ///   - element: The identifier or name of the UI element that was clicked.
    ///   - screen: (Optional) The name of the screen where the event occurred.
    ///   - sessionId: (Optional) The session ID to associate the event with.
    ///   - userProperties: (Optional) A dictionary of user-specific properties to log with the event.
    ///   - eventProperties: (Optional) A dictionary of additional event-specific properties to log.
    ///   - fields: A list of additional metadata fields to include, such as platform, language, or device type.
    @MainActor public func logClickEvent(
        userId: String,
        element: String,
        screen: String? = nil,
        sessionId: String? = nil,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        var eventProps: [String: Any] = [
            "element": element
        ]
        
        if let extraEventProps = eventProperties {
            eventProps.merge(extraEventProps) { _, new in new }
        }
        
        logEvent(
            userId: userId,
            eventType: "click_\(element)",
            screen: screen,
            sessionId: sessionId,
            userProperties: userProperties,
            eventProperties: eventProps,
            fields: fields
        )
    }
    
    /// Logs a screen navigation event in the application.
    /// This method captures transitions between screens, tracking details such as the source screen,
    /// destination screen, navigation duration, and additional metadata.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user who triggered the navigation event.
    ///   - fromScreen: The name of the screen the user navigated away from.
    ///   - toScreen: The name of the screen the user navigated to.
    ///   - sessionId: (Optional) The session ID to associate the navigation event with.
    ///   - duration: (Optional) The time interval (in seconds) the user spent on the previous screen before navigating.
    ///   - userProperties: (Optional) A dictionary of user-specific properties to log with the event.
    ///   - eventProperties: (Optional) A dictionary of additional event-specific properties to log.
    ///   - fields: A list of additional metadata fields to include, such as platform, language, or device type.
    @MainActor public func logScreenNavigation(
        userId: String,
        fromScreen: String,
        toScreen: String,
        sessionId: String? = nil,
        duration: TimeInterval? = nil,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        
        var eventProps: [String: Any] = [
            "from_screen": fromScreen,
            "to_screen": toScreen
        ]
        
        if let duration = duration {
            eventProps["duration"] = duration
        }
        
        if let additionalProps = eventProperties {
            eventProps.merge(additionalProps) { _, new in new }
        }
        
        logEvent(
            userId: userId,
            eventType: "screen_navigation",
            sessionId: sessionId,
            userProperties: userProperties,
            eventProperties: eventProps,
            fields: fields
        )
    }
    
    /// Logs the duration a user spends on a specific screen in the application.
    /// This method tracks how long a user remains on a screen and captures additional metadata if provided.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose screen duration is being logged.
    ///   - screen: The name of the screen where the duration was recorded.
    ///   - sessionId: (Optional) The session ID to associate with the event.
    ///   - duration: The time interval (in seconds) the user spent on the screen.
    ///   - userProperties: (Optional) A dictionary of user-specific properties to log with the event.
    ///   - eventProperties: (Optional) A dictionary of additional event-specific properties to log.
    ///   - fields: A list of additional metadata fields to include, such as platform, language, or device type.
    @MainActor public func logScreenDuration(
        userId: String,
        screen: String,
        sessionId: String? = nil,
        duration: TimeInterval,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        var eventProps: [String: Any] = ["duration": duration]
        if let additionalProps = eventProperties {
            eventProps.merge(additionalProps) { _, new in new }
        }
        
        logEvent(
            userId: userId,
            eventType: "screen_duration",
            screen: screen,
            sessionId: sessionId,
            userProperties: userProperties,
            eventProperties: eventProps,
            fields: fields
        )
    }
    
    /// Logs the duration of a user session in the application.
    /// This method captures the total time spent by a user during a specific session and records additional metadata if provided.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose session duration is being logged.
    ///   - sessionId: The unique identifier for the session.
    ///   - duration: The time interval (in seconds) representing the duration of the session.
    ///   - userProperties: (Optional) A dictionary of user-specific properties to include in the event.
    ///   - eventProperties: (Optional) A dictionary of additional event-specific properties to log.
    ///   - fields: A list of additional metadata fields to include, such as platform, app version, or device details.
    @MainActor
    public func logSessionDuration(
        userId: String,
        sessionId: String,
        duration: TimeInterval,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        
        var eventProps: [String: Any] = ["duration": duration]
        
        if let additionalProps = eventProperties {
            eventProps.merge(additionalProps) { _, new in new }
        }
        
        logEvent(
            userId: userId,
            eventType: "session_duration",
            sessionId: sessionId,
            userProperties: userProperties,
            eventProperties: eventProps,
            fields: fields
        )
    }
    
    /// Logs an event when the application is opened.
    /// This method captures the "open_app" event, which signifies that the user has launched the application.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user opening the application.
    ///   - screen: (Optional) The screen name that the user is presented with upon opening the app.
    ///   - sessionId: (Optional) The unique identifier for the current session.
    ///   - userProperties: (Optional) A dictionary of user-specific properties to include in the event.
    ///   - eventProperties: (Optional) A dictionary of additional event-specific properties to log.
    ///   - fields: A list of additional metadata fields to include, such as platform, app version, or device details.
    @MainActor public func logOpenAppEvent(
        userId: String,
        screen: String? = nil,
        sessionId: String? = nil,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        logEvent(
            userId: userId,
            eventType: "open_app",
            screen: screen,
            sessionId: sessionId,
            userProperties: userProperties,
            eventProperties: eventProperties,
            fields: fields
        )
    }
    
    /// Logs an event when the application is closed.
    /// This method records the "close_app" event, which signifies that the user has exited or closed the application.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user closing the application.
    ///   - screen: (Optional) The screen name the user was on when the application was closed.
    ///   - sessionId: (Optional) The unique identifier for the current session.
    ///   - userProperties: (Optional) A dictionary of user-specific properties to include in the event.
    ///   - eventProperties: (Optional) A dictionary of additional event-specific properties to log.
    ///   - fields: A list of additional metadata fields to include, such as platform, app version, or device details.
    @MainActor public func logCloseAppEvent(
        userId: String,
        screen: String? = nil,
        sessionId: String? = nil,
        userProperties: [String: Any]? = nil,
        eventProperties: [String: Any]? = nil,
        fields: [AnalyticsField] = []
    ) {
        
        logEvent(
            userId: userId,
            eventType: "close_app",
            screen: screen,
            sessionId: sessionId,
            userProperties: userProperties,
            eventProperties: eventProperties,
            fields: fields
        )
    }
}

extension AnalyticsManager {
    /// Retrieves the application version from the app's bundle.
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown Version"
    }
    
    /// Identifies the platform on which the application is running.
    private func getPlatform() -> String {
#if os(iOS)
        return "iOS"
#elseif os(macOS)
        return "macOS"
#elseif os(tvOS)
        return "tvOS"
#elseif os(watchOS)
        return "watchOS"
#else
        return "Unknown"
#endif
    }
    
    /// Retrieves the localized name of the user's current country based on the device's region settings.
    private func getCountryName() -> String? {
        let currentLocale = Locale.current
        if let regionCode = currentLocale.regionCode {
            return currentLocale.localizedString(forRegionCode: regionCode)
        }
        return nil
    }
    
    /// Retrieves the localized name of the user's preferred language based on the device's language settings.
    private func getLanguageName() -> String? {
        let currentLocale = Locale.current
        if let languageCode = currentLocale.languageCode {
            return currentLocale.localizedString(forLanguageCode: languageCode)
        }
        return nil
    }
}
