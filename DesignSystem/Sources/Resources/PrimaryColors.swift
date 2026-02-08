import SwiftUI

private let designSystemBundle = Bundle(identifier: "com.seungwan.CoachCoach.DesignSystem") ?? Bundle.main

public enum AppColor {
  public static let primaryBlue100 = Color("Primary-blue-100", bundle: designSystemBundle)
  public static let primaryBlue200 = Color("Primary-blue-200", bundle: designSystemBundle)
  public static let primaryBlue300 = Color("Primary-blue-300", bundle: designSystemBundle)
  public static let primaryBlue400 = Color("Primary-blue-400", bundle: designSystemBundle)
  public static let primaryBlue500 = Color("Primary-blue-500", bundle: designSystemBundle)
  public static let primaryBlue600 = Color("Primary-blue-600", bundle: designSystemBundle)
  public static let primaryBlue700 = Color("Primary-blue-700", bundle: designSystemBundle)
  public static let primaryBlue800 = Color("Primary-blue-800", bundle: designSystemBundle)
  public static let primaryBlue900 = Color("Primary-blue-900", bundle: designSystemBundle)
  public static let grayscale100 = Color("Grayscale-100", bundle: designSystemBundle)
  public static let grayscale200 = Color("Grayscale-200", bundle: designSystemBundle)
  public static let grayscale300 = Color("Grayscale-300", bundle: designSystemBundle)
  public static let grayscale400 = Color("Grayscale-400", bundle: designSystemBundle)
  public static let grayscale500 = Color("Grayscale-500", bundle: designSystemBundle)
  public static let grayscale600 = Color("Grayscale-600", bundle: designSystemBundle)
  public static let grayscale700 = Color("Grayscale-700", bundle: designSystemBundle)
  public static let grayscale800 = Color("Grayscale-800", bundle: designSystemBundle)
  public static let grayscale900 = Color("Grayscale-900", bundle: designSystemBundle)
  public static let semanticSafeText = Color("SemanticSafeText", bundle: designSystemBundle)
  public static let semanticSafe = Color("SemanticSafe", bundle: designSystemBundle)
  public static let semanticWarningText = Color("SemanticWarningText", bundle: designSystemBundle)
  public static let semanticWarning = Color("SemanticWarning", bundle: designSystemBundle)
  public static let semanticCautionText = Color("SemanticCautionText", bundle: designSystemBundle)
  public static let semanticCaution = Color("SemanticCaution", bundle: designSystemBundle)
  
  public static let error = Color(red: 235/255, green: 87/255, blue: 87/255)
}
