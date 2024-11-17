/// An enumeration representing the possible errors that can occur in analytics-related operations.
enum AnalyticsError: Error {
    case invalidURL
    case invalidPayload
    case serverError
    case networkError(Error)
}

