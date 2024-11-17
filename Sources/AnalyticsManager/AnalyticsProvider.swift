import Foundation

protocol AnalyticsProviderProtocol {
    func sendEvent(
        payload: [String: Any],
        completion: @escaping @Sendable (Result<Void, Error>) -> Void
    )
}

/// A class that sends events to an analytics service.
final class AnalyticsProvider: AnalyticsProviderProtocol {
    
    /// The URL of the analytics API endpoint.
    private let apiUrl: String
    
    init() {
        self.apiUrl = "https://api2.amplitude.com/2/httpapi"
    }
    
    /// Sends an event with the provided payload to the analytics service.
    /// - Parameters:
    ///   - payload: A dictionary containing the event data to be sent.
    ///   - completion: A closure to be called upon completion of the request. It provides a result indicating success or failure.
    func sendEvent(
        payload: [String: Any],
        completion: @escaping @Sendable (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: apiUrl) else {
            completion(.failure(AnalyticsError.invalidURL))
            return
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(AnalyticsError.invalidPayload))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(AnalyticsError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(AnalyticsError.serverError))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }
}
