import SwiftUI
import SwiftUI
import ComposableArchitecture
import DesignSystem
import DataLayer
import CoreModels

public struct HomeView: View {
  let store: StoreOf<HomeFeature>
  @AppStorage("storeName") private var storeName: String = ""
  @AppStorage("unreadNotificationCount") private var unreadNotificationCount: Int = 0

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale200
          .ignoresSafeArea()
          VStack {
              header
                  .frame(maxHeight: 56)
              ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                  headlineSection
                        .padding(.bottom, 8)
                    

                  if let stats = viewStore.dashboardStats {
                    diagnosisBanner(count: stats.diagnosisNeededCount, viewStore: viewStore)
                    profitSummarySection(stats: stats)
                  }

                  strategyGuideSection(guides: viewStore.strategyGuides, error: viewStore.error, viewStore: viewStore)
                }
              }
          }
          .padding(.horizontal, 24)



        if viewStore.isLoading && viewStore.dashboardStats == nil {
          ProgressView()
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
  
  private var header: some View {
      HStack(spacing: 12 ) {
      Image.coachCoachLogo
        .resizable()
        .scaledToFit()
        .frame(width: 72, height: 15)

      Spacer()

      Button(action: {}) {
        ZStack(alignment: .topTrailing) {
          Image.bellIcon
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(AppColor.grayscale700)
            .frame(width: 24, height: 24)

          if unreadNotificationCount > 0 {
            ZStack {
              Circle()
                .fill(AppColor.error)
                .frame(width: 12, height: 12)

              Text(String(unreadNotificationCount))
                .font(.pretendardCaption2)
                .foregroundColor(.white)
            }
            .offset(x: 4, y: -4)
          }
        }
      }
      .buttonStyle(.plain)

      NavigationLink(value: HomeRoute.settings) {
        Image.gearIcon
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .foregroundColor(AppColor.grayscale700)
          .frame(width: 24, height: 24)
      }
      .buttonStyle(.plain)
    }
  }

  private var headlineSection: some View {
    HStack(alignment: .top, spacing: 16) {
      Text("\(storeDisplayName)의 수익 상황을\n확인하세요")
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
        .lineSpacing(4)

      Spacer(minLength: 0)
    }
  }

  private var storeDisplayName: String {
    let trimmed = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "우리 매장" : trimmed
  }
  
  private func diagnosisBanner(count: Int, viewStore: ViewStoreOf<HomeFeature>) -> some View {
    Button(action: { viewStore.send(.diagnosisBannerTapped) }) {
      HStack(spacing: 4) {
        Text("진단이 필요한 메뉴")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)

        Text("\(count)개")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.semanticWarningText)
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
          .background(
            Capsule(style: .continuous)
              .fill(AppColor.semanticWarning)
          )


        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale400)
      }
      .frame(minHeight: 26)
      .padding(.leading, 20)
      .padding(.trailing, 12)
      .padding(.vertical, 8)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
  }
  
  private func strategyGuideSection(
    guides: [StrategyGuideItem],
    error: String?,
    viewStore: ViewStoreOf<HomeFeature>
  ) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("전략 가이드")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)

        Spacer()

        Button(action: { viewStore.send(.strategyGuideTapped) }) {
          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale600)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 20)
      .padding(.top, 20)

      VStack(spacing: 0) {
        if guides.isEmpty {
          VStack(spacing: 6) {
            Text(error == nil ? "이번 주 전략이 없어요" : "전략 가이드를 불러오지 못했어요")
              .font(.pretendardSubtitle2)
              .foregroundColor(AppColor.grayscale700)
            Text(error ?? "데이터가 쌓이면 전략 가이드가 보여요")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale500)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 28)
        } else {
          ForEach(Array(guides.prefix(3).enumerated()), id: \.offset) { index, guide in
            VStack(alignment: .leading, spacing: 8) {
              Text(guide.title)
                .font(.pretendardBody1)
                .foregroundColor(AppColor.grayscale900)
              Text(guide.summary)
                .font(.caption2)
                .foregroundColor(AppColor.grayscale700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)

            if index < min(guides.count, 3) - 1 {
              Divider()
                .padding(.horizontal, 20)
                .background(AppColor.grayscale200)
            }
          }
        }
      }
      .padding(.top, 8)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }
  
  private func profitSummarySection(stats: DashboardStats) -> some View {
    HStack(spacing: 12) {
      ProfitSummaryCard(
        title: "평균 원가율",
        value: stats.averageCostRate,
        status: stats.averageCostRateStatus
      )
      ProfitSummaryCard(
        title: "평균마진율",
        value: stats.contributionMarginRate,
        status: nil
      )
    }
  }
}

private struct ProfitSummaryCard: View {
  let title: String
  let value: String
  let status: MenuStatus?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 8) {
        Text(title)
              .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)

        if let status {
          MenuStatusBadge(status: status)
        }
      }
      .frame(minHeight: 20)

      Spacer(minLength: 0)

      Text(value)
        .font(.pretendardHeadline1)
        .foregroundColor(AppColor.grayscale900)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .frame(maxWidth: .infinity,alignment: .leading)
    .frame(height: 98)
    .padding(.vertical, 12)
    .padding(.horizontal, 16)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }
}

private struct WeeklyGuideDetailView: View {
  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
    }
  }
}

private struct ResolvedHistoryView: View {
  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
    }
  }
}

private struct StoreInfoEditView: View {
  @Environment(\.dismiss) private var dismiss

  @AppStorage("storeName") private var storeName: String = ""
  @AppStorage("employees") private var employees: Int = 0
  @AppStorage("laborCost") private var laborCost: Int = 0
  @AppStorage("includeWeeklyHolidayPay") private var includeWeeklyHolidayPay: Bool = false

  @State private var storeNameText: String = ""
  @State private var staffCountText: String = ""
  @State private var laborCostText: String = ""
  @State private var isSoloWorker = false
  @State private var isStaffCountFocused = false
  @State private var isLaborCostFocused = false
  @State private var showLaborCostTooltip = false
  @State private var isSaving = false
  @State private var saveError: String?

  var body: some View {
    VStack(spacing: 0) {
      NavigationTopBar(onBackTap: { dismiss() })

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          storeNameSection

          sectionBlockDivider

          staffCountSection
          laborCostSection

          if let saveError {
            Text(saveError)
              .font(.pretendardCaption2)
              .foregroundColor(AppColor.error)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 100)
      }

      Spacer(minLength: 0)

      BottomButton(
        title: "수정하기",
        style: isSaveEnabled ? .primary : .secondary
      ) {
        saveAndDismiss()
      }
      .disabled(!isSaveEnabled)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      storeNameText = storeName
      staffCountText = employees == 0 ? "0" : String(employees)
      laborCostText = laborCost == 0 ? "" : String(laborCost)
      isSoloWorker = employees == 0
    }
  }

  private var isSaveEnabled: Bool {
    !storeNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      &&
    !staffCountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !laborCostText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !isSaving
  }

  private var staffCountBinding: Binding<String> {
    Binding(
      get: { staffCountText },
      set: { staffCountText = sanitizedDigits($0) }
    )
  }

  private var laborCostBinding: Binding<String> {
    Binding(
      get: { laborCostText },
      set: { laborCostText = sanitizedDigitsAndCommas($0) }
    )
  }

  private var storeNameSection: some View {
    UnderlinedTextField(
      text: $storeNameText,
      title: "매장명",
      placeholder: "매장명 입력",
      titleColor: AppColor.grayscale700,
      placeholderColor: AppColor.grayscale400,
      underlineColor: AppColor.grayscale300,
      accentColor: AppColor.primaryBlue500
    )
  }

  private var sectionBlockDivider: some View {
    Rectangle()
      .fill(AppColor.grayscale200)
      .frame(height: 10)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, -20)
  }

  private var staffCountSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      staffCountField

      checkboxRow(isChecked: isSoloWorker, label: "사장님 혼자 근무중이신가요?") {
        isSoloWorker.toggle()
        staffCountText = isSoloWorker ? "0" : ""
      }
    }
  }

  private var laborCostSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      laborCostField

      checkboxRow(
        isChecked: includeWeeklyHolidayPay,
        label: "주휴수당 포함"
      ) {
        includeWeeklyHolidayPay.toggle()
      }

      minimumWageInfoBox
    }
  }

  private var staffCountField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("직원수")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale700)

      if isStaffCountFocused {
        TextField(
          "",
          text: staffCountBinding,
          prompt: Text("사장님을 제외한 직원수 입력")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale400)
        )
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .onSubmit { isStaffCountFocused = false }
      } else {
        Text(formattedStaffCount(staffCountText))
          .font(.pretendardSubTitle)
          .foregroundColor(staffCountText.isEmpty ? AppColor.grayscale400 : AppColor.grayscale900)
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 26)
          .contentShape(Rectangle())
          .onTapGesture {
            isStaffCountFocused = true
          }
      }

      Rectangle()
        .fill(isStaffCountFocused ? AppColor.primaryBlue500 : AppColor.grayscale300)
        .frame(height: 1)
    }
  }

  private var laborCostField: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 4) {
        Text("인건비")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale700)

        Button {
          showLaborCostTooltip.toggle()
        } label: {
          Image(systemName: "questionmark.circle.fill")
            .font(.system(size: 14))
            .foregroundColor(AppColor.grayscale400)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottomLeading) {
          if showLaborCostTooltip {
            tooltipBubble(text: "현재 근무중인 직원의 평균 시급")
              .fixedSize()
              .offset(x: -10, y: -22)
          }
        }
        .zIndex(1)
      }

      if isLaborCostFocused {
        TextField(
          "",
          text: laborCostBinding,
          prompt: Text("시급 기준으로 입력")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale400)
        )
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .onSubmit { isLaborCostFocused = false }
      } else {
        Text(formattedLaborCost(laborCostText))
          .font(.pretendardBody2)
          .foregroundColor(
            laborCostText.isEmpty ? AppColor.grayscale400 : AppColor.grayscale900
          )
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 24)
          .contentShape(Rectangle())
          .onTapGesture {
            isLaborCostFocused = true
          }
      }

      Rectangle()
        .fill(isLaborCostFocused ? AppColor.primaryBlue500 : AppColor.grayscale300)
        .frame(height: 1)
    }
  }

  private func formattedLaborCost(_ value: String) -> String {
    guard !value.isEmpty else { return "시급 기준으로 입력" }
    let cleaned = value.replacingOccurrences(of: ",", with: "")
    guard let number = Int(cleaned.filter({ $0.isNumber })) else { return value }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let formatted = formatter.string(from: NSNumber(value: number)) ?? value
    return "\(formatted)원"
  }

  private func sanitizedDigits(_ value: String) -> String {
    value.filter(\.isNumber)
  }

  private func sanitizedDigitsAndCommas(_ value: String) -> String {
    value.filter { $0.isNumber || $0 == "," }
  }

  private func formattedStaffCount(_ value: String) -> String {
    guard !value.isEmpty else { return "사장님을 제외한 직원수 입력" }
    let digits = value.filter { $0.isNumber }
    guard let number = Int(digits) else { return value }
    return "\(number)명"
  }

  private func checkboxRow(isChecked: Bool, label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 8) {
        StoreOperationCheckbox(isChecked: isChecked)

        Text(label)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale700)
      }
    }
    .buttonStyle(.plain)
  }

  private func tooltipBubble(text: String) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(text)
        .font(.pretendardCaption2)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColor.grayscale800)
        .cornerRadius(8)

      TooltipTriangle()
        .fill(AppColor.grayscale800)
        .frame(width: 12, height: 6)
        .padding(.leading, 10)
    }
  }

  private var minimumWageInfoBox: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("참고해보세요")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.primaryBlue500)

      (Text("2026년 기준 ")
        .foregroundColor(AppColor.grayscale600)
      + Text("최저시급은 10,320원")
        .foregroundColor(AppColor.grayscale900)
        .bold()
      + Text(" 이에요")
        .foregroundColor(AppColor.grayscale600))
      .font(.pretendardBody2)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.primaryBlue100)
    .cornerRadius(12)
  }

  private func saveAndDismiss() {
    guard !isSaving else { return }

    let trimmedName = storeNameText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else {
      saveError = "매장명이 없어 수정할 수 없어요"
      return
    }

    let staffDigits = staffCountText.filter { $0.isNumber }
    let staff = Int(staffDigits) ?? 0
    let laborDigits = laborCostText.filter { $0.isNumber }
    let labor = Double(laborDigits) ?? 0

    isSaving = true
    saveError = nil

    Task {
      do {
        try await UserRepository.liveValue.updateStore(
          trimmedName,
          staff,
          labor,
          includeWeeklyHolidayPay
        )

        await MainActor.run {
          storeName = trimmedName
          employees = staff
          laborCost = Int(labor)
          isSaving = false
          dismiss()
        }
      } catch {
        await MainActor.run {
          isSaving = false
          saveError = errorMessage(error)
        }
      }
    }
  }

  private func errorMessage(_ error: Error) -> String {
    if let apiError = error as? APIError {
      return apiError.message
    }
    return error.localizedDescription
  }

  private struct StoreOperationCheckbox: View {
    let isChecked: Bool

    var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: isChecked ? 2 : 1.25)
          .fill(isChecked ? AppColor.primaryBlue500 : Color.clear)
          .overlay(
            Group {
              if !isChecked {
                RoundedRectangle(cornerRadius: 1.25)
                  .stroke(Color(red: 0.788, green: 0.82, blue: 0.871), lineWidth: 1.5)
              }
            }
          )

        StoreCheckmarkShape()
          .fill(isChecked ? Color.white : Color(red: 0.788, green: 0.82, blue: 0.871))
      }
      .frame(width: 18, height: 18)
    }
  }

  private struct StoreCheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
      let scaleX = rect.width / 18
      let scaleY = rect.height / 18

      var path = Path()
      path.move(to: CGPoint(x: 6.9998 * scaleX, y: 10.8875 * scaleY))
      path.addLine(to: CGPoint(x: 12.8998 * scaleX, y: 4.9875 * scaleY))
      path.addCurve(
        to: CGPoint(x: 13.5998 * scaleX, y: 4.7125 * scaleY),
        control1: CGPoint(x: 13.0831 * scaleX, y: 4.8042 * scaleY),
        control2: CGPoint(x: 13.3165 * scaleX, y: 4.7125 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 14.2998 * scaleX, y: 4.9875 * scaleY),
        control1: CGPoint(x: 13.8831 * scaleX, y: 4.7125 * scaleY),
        control2: CGPoint(x: 14.1165 * scaleX, y: 4.8042 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 14.5748 * scaleX, y: 5.6875 * scaleY),
        control1: CGPoint(x: 14.4831 * scaleX, y: 5.1709 * scaleY),
        control2: CGPoint(x: 14.5748 * scaleX, y: 5.4042 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 14.2998 * scaleX, y: 6.3875 * scaleY),
        control1: CGPoint(x: 14.5748 * scaleX, y: 5.9709 * scaleY),
        control2: CGPoint(x: 14.4831 * scaleX, y: 6.2042 * scaleY)
      )
      path.addLine(to: CGPoint(x: 7.6998 * scaleX, y: 12.9875 * scaleY))
      path.addCurve(
        to: CGPoint(x: 6.9998 * scaleX, y: 13.2875 * scaleY),
        control1: CGPoint(x: 7.4998 * scaleX, y: 13.1875 * scaleY),
        control2: CGPoint(x: 7.2665 * scaleX, y: 13.2875 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 6.2998 * scaleX, y: 12.9875 * scaleY),
        control1: CGPoint(x: 6.7331 * scaleX, y: 13.2875 * scaleY),
        control2: CGPoint(x: 6.4998 * scaleX, y: 13.1875 * scaleY)
      )
      path.addLine(to: CGPoint(x: 3.6998 * scaleX, y: 10.3875 * scaleY))
      path.addCurve(
        to: CGPoint(x: 3.4248 * scaleX, y: 9.6875 * scaleY),
        control1: CGPoint(x: 3.5165 * scaleX, y: 10.2042 * scaleY),
        control2: CGPoint(x: 3.4248 * scaleX, y: 9.9709 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 3.6998 * scaleX, y: 8.9875 * scaleY),
        control1: CGPoint(x: 3.4248 * scaleX, y: 9.4042 * scaleY),
        control2: CGPoint(x: 3.5165 * scaleX, y: 9.1709 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 4.3998 * scaleX, y: 8.7125 * scaleY),
        control1: CGPoint(x: 3.8831 * scaleX, y: 8.8042 * scaleY),
        control2: CGPoint(x: 4.1165 * scaleX, y: 8.7125 * scaleY)
      )
      path.addCurve(
        to: CGPoint(x: 5.0998 * scaleX, y: 8.9875 * scaleY),
        control1: CGPoint(x: 4.6831 * scaleX, y: 8.7125 * scaleY),
        control2: CGPoint(x: 4.9165 * scaleX, y: 8.8042 * scaleY)
      )
      path.addLine(to: CGPoint(x: 6.9998 * scaleX, y: 10.8875 * scaleY))
      path.closeSubpath()
      return path
    }
  }

  private struct TooltipTriangle: Shape {
    func path(in rect: CGRect) -> Path {
      var path = Path()
      path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
      path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
      path.closeSubpath()
      return path
    }
  }
}

public struct HomeSettingsView: View {
  @Environment(\.dismiss) private var dismiss

  private let onLogoutConfirmed: () -> Void
  private let onWithdrawalConfirmed: () -> Void

  @State private var isLogoutAlertPresented = false

  @AppStorage("storeName") private var storeName: String = ""
  @AppStorage("employees") private var employees: Int = 0
  @AppStorage("laborCost") private var laborCost: Int = 0
  @AppStorage("includeWeeklyHolidayPay") private var includeWeeklyHolidayPay: Bool = false
  @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

  @State private var storeLoadError: String?

  public init(
    onLogoutConfirmed: @escaping () -> Void = {},
    onWithdrawalConfirmed: @escaping () -> Void = {}
  ) {
    self.onLogoutConfirmed = onLogoutConfirmed
    self.onWithdrawalConfirmed = onWithdrawalConfirmed
  }

  public var body: some View {
    VStack(spacing: 0) {
      settingsHeader

      ScrollView {
        VStack(spacing: 12) {
          storeInfoCard
        //TODO: Next Version
        //  managementCard
          infoCard
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 24)
      }

      Spacer(minLength: 0)

      Button(action: { isLogoutAlertPresented = true }) {
        Text("로그아웃")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale600)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
      }
      .buttonStyle(.plain)
      .padding(.bottom, 16)
    }
    .background(AppColor.grayscale200.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .coachCoachAlert(
      isPresented: $isLogoutAlertPresented,
      title: "로그아웃 하시겠습니까?",
      alertType: .twoButton,
      leftButtonTitle: "아니오",
      rightButtonTitle: "확인",
      rightButtonAction: {
        onLogoutConfirmed()
      }
    )
    .task {
      await loadStoreInfo()
    }
  }

  private var settingsHeader: some View {
    HStack {
      Button(action: { dismiss() }) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)

      Spacer()

      Text("설정")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)

      Spacer()

      Color.clear
        .frame(width: 20, height: 20)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(AppColor.grayscale200)
  }

  private var storeInfoCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top) {
        Text("매장 정보")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)

        Spacer(minLength: 0)

        NavigationLink {
          StoreInfoEditView()
        } label: {
          Text("수정")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColor.grayscale300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
      }

      Text(storeName.isEmpty ? "매장명 미설정" : storeName)
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)

      VStack(spacing: 12) {
        metric(label: "직원", value: "\(employees)명")
        metric(label: "인건비", value: formattedLaborCost)

        if let storeLoadError {
          Text(storeLoadError)
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.error)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
    .padding(16)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  private var formattedLaborCost: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let formatted = formatter.string(from: NSNumber(value: laborCost)) ?? "0"
    return "\(formatted)원"
  }

  private func metric(label: String, value: String) -> some View {
    HStack(spacing: 12) {
      Text(label)
        .frame(width: 48, alignment: .leading)
        .font(.pretendardCaption2)
        .foregroundColor(AppColor.grayscale600)

      Text(value)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
        .frame(minWidth: 92, alignment: .leading)
    }
  }

  private func loadStoreInfo() async {
    do {
      let store = try await UserRepository.liveValue.fetchStore()
      await MainActor.run {
        storeName = store.name
        employees = store.employees
        laborCost = Int(store.laborCost)
        includeWeeklyHolidayPay = store.includeWeeklyHolidayPay ?? includeWeeklyHolidayPay
        storeLoadError = nil
      }
    } catch {
      await MainActor.run {
        storeLoadError = errorMessage(error)
      }
    }
  }

  private func errorMessage(_ error: Error) -> String {
    if let apiError = error as? APIError {
      return apiError.message
    }
    return error.localizedDescription
  }

  private var managementCard: some View {
    VStack(spacing: 8) {
      Button(action: {}) {
        HStack {
          Text("구독관리")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)

          Spacer(minLength: 0)

          HStack(spacing: 6) {
            Text("요금제 구독중")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.primaryBlue500)
            Image.chevronRightOutlineIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.primaryBlue500)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      }
      .buttonStyle(.plain)
//
//      HStack {
//        Text("알림")
//          .font(.pretendardBody2)
//          .foregroundColor(AppColor.grayscale900)
//
//        Spacer(minLength: 0)
//
//        Toggle("", isOn: $notificationsEnabled)
//          .labelsHidden()
//          .tint(AppColor.primaryBlue500)
//      }
//      .padding(.horizontal, 20)
//      .padding(.vertical, 16)
//      .background(Color.white)
//      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
  }

  private var infoCard: some View {
    VStack(spacing: 0) {
//      settingsRow(title: "FAQ")

//      Divider()
//        .foregroundColor(AppColor.grayscale300)

//      settingsRow(title: "이용약관")

      Divider()
        .foregroundColor(AppColor.grayscale300)

      settingsNavigationRow(title: "회원탈퇴") {
        AccountWithdrawalView(onWithdrawalConfirmed: onWithdrawalConfirmed)
      }
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  private func settingsRow(title: String) -> some View {
    Button(action: {}) {
      HStack {
        Text(title)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)

        Spacer(minLength: 0)

        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale500)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
    }
    .buttonStyle(.plain)
  }

  private func settingsNavigationRow<Destination: View>(
    title: String,
    @ViewBuilder destination: () -> Destination
  ) -> some View {
    NavigationLink(destination: destination()) {
      HStack {
        Text(title)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)

        Spacer(minLength: 0)

        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale500)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
    }
    .buttonStyle(.plain)
  }
}

private struct AccountWithdrawalView: View {
  @Environment(\.dismiss) private var dismiss

  let onWithdrawalConfirmed: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button(action: { dismiss() }) {
          Image.arrowLeftIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale900)
            .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 12)

      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          Text("정말 탈퇴하시겠어요?")
            .font(.pretendardTitle2)
            .foregroundColor(AppColor.grayscale900)

          withdrawalDescription
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
      }

      Spacer(minLength: 0)

      BottomButton(
        title: "탈퇴하기",
        style: .primary
      ) {
        onWithdrawalConfirmed()
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 12)
    }
    .background(AppColor.grayscale200.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
  }

  private var withdrawalDescription: some View {
    VStack(alignment: .leading, spacing: 10) {
      (highlightedWord("회원") + normalText(" 탈퇴를 진행하면 즉시 계정이 삭제되며 서비스 이용이 불가합니다."))

      normalText("탈퇴 후에는 기존 데이터가 복구되지 않습니다.")
      normalText("탈퇴 즉시 계정 정보(아이디, 비밀번호 등)는 지체 없이 삭제됩니다.")
      normalText("단, 관련 법령에 따라 결제/거래 기록 등 일부 정보는 일정 기간 보관될 수 있습니다.")

      (highlightedWord("회원") + normalText(" 탈퇴와 관련한 문의는 이메일을 통해 문의하실 수 있습니다."))

      Text("coach.operation@gmail.com")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
    }
  }

  private func normalText(_ content: String) -> Text {
    Text(content)
      .font(.pretendardBody2)
      .foregroundColor(AppColor.grayscale900)
  }

  private func highlightedWord(_ content: String) -> Text {
    Text(content)
      .font(.pretendardBody2)
      .foregroundColor(AppColor.grayscale900)
  }
}

#Preview {
  HomeView(
    store: Store(initialState: HomeFeature.State()) {
      HomeFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
