import Foundation

public enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case patch = "PATCH"
  case delete = "DELETE"
}

public enum APIError: Error, Equatable {
  case invalidURL
  case networkError(String)
  case decodingError(String)
  case serverError(Int, String)
  case unknown
}

public struct APIClient: Sendable {
  private let baseURL: String
  private let session: URLSession
  private let defaultHeaders: [String: String]
  
  public init(
    baseURL: String = "http://3.36.186.131",
    session: URLSession = .shared,
    defaultHeaders: [String: String] = ["userId": "1", "laborCost": "10320"]
  ) {
    self.baseURL = baseURL
    self.session = session
    self.defaultHeaders = defaultHeaders
  }
  
  public func request<T: Decodable>(
    path: String,
    method: HTTPMethod = .get,
    queryItems: [URLQueryItem]? = nil,
    body: (any Encodable)? = nil,
    headers: [String: String]? = nil
  ) async throws -> T {
    guard var urlComponents = URLComponents(string: baseURL + path) else {
      throw APIError.invalidURL
    }
    
    if let queryItems = queryItems {
      urlComponents.queryItems = queryItems
    }
    
    guard let url = urlComponents.url else {
      throw APIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    for (key, value) in defaultHeaders {
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if let headers = headers {
      for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    if method != .get, let body = body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(body)
    }
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.unknown
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw APIError.serverError(httpResponse.statusCode, errorMessage)
    }
    
    do {
      let decoded = try JSONDecoder().decode(T.self, from: data)
      return decoded
    } catch {
      throw APIError.decodingError(error.localizedDescription)
    }
  }
  
  public func requestVoid(
    path: String,
    method: HTTPMethod = .post,
    queryItems: [URLQueryItem]? = nil,
    body: (any Encodable)? = nil,
    headers: [String: String]? = nil
  ) async throws {
    guard var urlComponents = URLComponents(string: baseURL + path) else {
      throw APIError.invalidURL
    }
    
    if let queryItems = queryItems {
      urlComponents.queryItems = queryItems
    }
    
    guard let url = urlComponents.url else {
      throw APIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    for (key, value) in defaultHeaders {
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if let headers = headers {
      for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    if method != .get, let body = body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(body)
    }
    
    let (_, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.unknown
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      throw APIError.serverError(httpResponse.statusCode, "Request failed")
    }
  }
}
