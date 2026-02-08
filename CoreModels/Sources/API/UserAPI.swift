import Foundation

public struct OnboardingRequest: Codable, Equatable {
  public let name: String
  public let employees: Int
  public let laborCost: Double
  public let rentCost: Double?
  public let includeWeeklyHolidayPay: Bool?
  
  public init(
    name: String,
    employees: Int,
    laborCost: Double,
    rentCost: Double? = nil,
    includeWeeklyHolidayPay: Bool? = nil
  ) {
    self.name = name
    self.employees = employees
    self.laborCost = laborCost
    self.rentCost = rentCost
    self.includeWeeklyHolidayPay = includeWeeklyHolidayPay
  }
}
