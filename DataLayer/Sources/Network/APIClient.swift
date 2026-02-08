import Foundation
import CoreModels

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
  
  public var message: String {
    switch self {
    case .invalidURL:
      return "잘못된 요청입니다."
    case .networkError(let message):
      return message
    case .decodingError:
      return "데이터 처리 중 오류가 발생했습니다."
    case .serverError(_, let message):
      return message
    case .unknown:
      return "알 수 없는 오류가 발생했습니다."
    }
  }
}

public struct APIClient: Sendable {
  private let baseURL: String
  private let session: URLSession
  private let defaultHeaders: [String: String]
  private let tokenStorage: TokenStorage
  private let keychainStorage: KeychainStorage
  
  public init(
    baseURL: String = "http://3.36.186.131",
    session: URLSession = .shared,
    defaultHeaders: [String: String] = ["userId": "1", "laborCost": "10320"],
    tokenStorage: TokenStorage = .shared,
    keychainStorage: KeychainStorage = .shared
  ) {
    self.baseURL = baseURL
    self.session = session
    self.defaultHeaders = defaultHeaders
    self.tokenStorage = tokenStorage
    self.keychainStorage = keychainStorage
  }
  
  public func request<T: Decodable>(
    path: String,
    method: HTTPMethod = .get,
    queryItems: [URLQueryItem]? = nil,
    body: (any Encodable)? = nil,
    headers: [String: String]? = nil,
    isRetry: Bool = false
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
    
    var finalHeaders = defaultHeaders
    
    if let token = await tokenStorage.getAccessToken() {
      finalHeaders["Authorization"] = "Bearer \(token)"
      finalHeaders.removeValue(forKey: "userId")
    }
    
    if let headers = headers {
      for (key, value) in headers {
        finalHeaders[key] = value
      }
    }
    
    for (key, value) in finalHeaders {
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if method != .get, let body = body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(body)
    }
    
    print("🌐 Request: \(method.rawValue) \(url.absoluteString)")
    if let token = await tokenStorage.getAccessToken() {
      print("🔑 Token: \(token)")
    }
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.unknown
    }
    
    if httpResponse.statusCode == 401 && !isRetry && !path.contains("/auth/") {
      print("⚠️ 401 Unauthorized - Attempting token refresh")
      
      do {
        try await refreshAccessToken()
        print("✅ Token refreshed - Retrying original request")
        return try await self.request(
          path: path,
          method: method,
          queryItems: queryItems,
          body: body,
          headers: headers,
          isRetry: true
        )
      } catch {
        print("❌ Token refresh failed: \(error)")
        throw APIError.serverError(401, "Authentication failed")
      }
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      let errorMessage: String
      if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
         let message = errorResponse.message {
        errorMessage = message
      } else {
        errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
      }
      throw APIError.serverError(httpResponse.statusCode, errorMessage)
    }
    
    do {
      let decoded = try JSONDecoder().decode(T.self, from: data)
      return decoded
    } catch {
      if let jsonString = String(data: data, encoding: .utf8) {
        print("❌ Decoding Error: \(error)")
        print("❌ Response Body: \(jsonString)")
      }
      throw APIError.decodingError(error.localizedDescription)
    }
  }
  
  public func requestVoid(
    path: String,
    method: HTTPMethod = .post,
    queryItems: [URLQueryItem]? = nil,
    body: (any Encodable)? = nil,
    headers: [String: String]? = nil,
    isRetry: Bool = false
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
    
    var finalHeaders = defaultHeaders
    
    if let token = await tokenStorage.getAccessToken() {
      finalHeaders["Authorization"] = "Bearer \(token)"
      finalHeaders.removeValue(forKey: "userId")
    }
    
    if let headers = headers {
      for (key, value) in headers {
        finalHeaders[key] = value
      }
    }
    
    for (key, value) in finalHeaders {
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if method != .get, let body = body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(body)
    }
    
    print("🌐 Request: \(method.rawValue) \(url.absoluteString)")
    if let token = await tokenStorage.getAccessToken() {
      print("🔑 Token: \(token)")
    }
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.unknown
    }
    
    if httpResponse.statusCode == 401 && !isRetry && !path.contains("/auth/") {
      print("⚠️ 401 Unauthorized - Attempting token refresh")
      
      do {
        try await refreshAccessToken()
        print("✅ Token refreshed - Retrying original request")
        return try await self.requestVoid(
          path: path,
          method: method,
          queryItems: queryItems,
          body: body,
          headers: headers,
          isRetry: true
        )
      } catch {
        print("❌ Token refresh failed: \(error)")
        throw APIError.serverError(401, "Authentication failed")
      }
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      let errorMessage: String
      if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
         let message = errorResponse.message {
        errorMessage = message
      } else {
        errorMessage = String(data: data, encoding: .utf8) ?? "Request failed"
      }
      throw APIError.serverError(httpResponse.statusCode, errorMessage)
    }
  }
  
  private func refreshAccessToken() async throws {
    guard let refreshToken = await keychainStorage.getRefreshToken() else {
      throw APIError.networkError("No refresh token available")
    }
    
    let request = TokenRefreshRequest(refreshToken: refreshToken)
    let response: BaseResponse<TokenRefreshResponse> = try await self.request(
      path: "/api/v1/auth/refresh",
      method: .post,
      body: request,
      isRetry: true
    )
    
    guard let data = response.data else {
      throw APIError.decodingError("Missing token data")
    }
    
    await tokenStorage.setAccessToken(data.accessToken)
    print("✅ Access token refreshed and stored")
  }
}
