import SwiftUI
import SwiftUI
import ComposableArchitecture
import DesignSystem
import DataLayer

public struct HomeView: View {
  let store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        if viewStore.isLoading {
          ProgressView()
        } else {
          ScrollView {
            VStack(alignment: .leading, spacing: 24) {
              header
              if let stats = viewStore.dashboardStats {
                diagnosisBanner(count: stats.diagnosisNeededCount)
              }
              strategyGuideSection(guides: viewStore.strategyGuides)
              if let stats = viewStore.dashboardStats {
                profitSummarySection(stats: stats)
              }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
          }
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
  
  private var header: some View {
    HStack {
      Text("코치코치")
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.primaryBlue500)
      Spacer()
      NavigationLink(value: HomeRoute.settings) {
        Image.menuRoundedIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale700)
      }
    }
  }
  
  private func diagnosisBanner(count: Int) -> some View {
    HStack {
      Text("진단이 필요한 메뉴")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale100)
      Spacer()
      HStack(spacing: 6) {
        Text("\(count) 개")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale100)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(AppColor.primaryBlue500)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
  
  private func strategyGuideSection(guides: [StrategyGuideItem]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader(title: "전략 가이드", actionTitle: "자세히", route: .weeklyGuide)
      StrategyGuideCard(guides: guides)
    }
    .shadow(.sm)
  }
  
  private func profitSummarySection(stats: DashboardStats) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("수익 진단")
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale900)
      HStack(spacing: 12) {
        ProfitSummaryCard(
          title: "평균 원가율",
          value: stats.averageCostRate,
          description: stats.averageCostRateDescription
        )
        ProfitSummaryCard(
          title: "공헌이익율",
          value: stats.contributionMarginRate,
          description: stats.contributionMarginRateDescription
        )
      }
    }
    .shadow(.sm)
  }
}

  private struct SectionHeader: View {
    let title: String
    let actionTitle: String
    let route: HomeRoute
  
  var body: some View {
    HStack {
      Text(title)
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
      Spacer()
      NavigationLink(value: route) {
        HStack(spacing: 0) {
          Text(actionTitle)
            .font(.pretendardCTA)
          Image.chevronRightOutlineIcon
        }
        .foregroundColor(AppColor.grayscale600)
      }
    }
  }
}

private struct StrategyGuideCard: View {
  let guides: [StrategyGuideItem]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      ForEach(guides) { guide in
        StrategyGuideRow(
          summary: guide.summary,
          title: guide.title,
          action: guide.action
        )
      }
    }
    .frame(maxWidth: .infinity)
    .padding(16)
    .background(AppColor.grayscale100)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: AppColor.grayscale900.opacity(0.06), radius: 8, x: 0, y: 4)
  }
}

private struct StrategyGuideRow: View {
  let summary: String
  let title: String
  let action: String
  
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 8) {
        Text(summary)
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale700)
        HStack(spacing: 6) {
          Text(title)
            .font(.pretendardBody1)
            .foregroundColor(AppColor.grayscale900)
          Text(action)
            .font(.pretendardBody1)
            .foregroundColor(AppColor.primaryBlue500)
        }
      }
      Spacer()
    }

  }
}

private struct ProfitSummaryCard: View {
  let title: String
  let value: String
  let description: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.pretendardCaption)
        .foregroundColor(AppColor.primaryBlue500)
        .padding(6)
        .background(AppColor.primaryBlue100)
        .clipShape(RoundedRectangle(cornerRadius: 6))
      Text(value)
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.grayscale900)
      Text(description)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)
        .padding(.top, 4)
      Spacer()
        .frame(height: 20)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(
      LinearGradient(
        stops: [
          Gradient.Stop(color: AppColor.grayscale100, location: 0.00),
          Gradient.Stop(color: AppColor.primaryBlue200, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0.27),
        endPoint: UnitPoint(x: 0.5, y: 1.32)
      )
    )    .clipShape(RoundedRectangle(cornerRadius: 12))
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

public struct HomeSettingsView: View {
  @Environment(\.dismiss) private var dismiss

  private let onLogoutConfirmed: () -> Void

  @State private var isLogoutAlertPresented = false

  @AppStorage("storeName") private var storeName: String = ""
  @AppStorage("employees") private var employees: Int = 0
  @AppStorage("laborCost") private var laborCost: Int = 0
  @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

  public init(onLogoutConfirmed: @escaping () -> Void = {}) {
    self.onLogoutConfirmed = onLogoutConfirmed
  }

  public var body: some View {
    VStack(spacing: 0) {
      settingsHeader

      ScrollView {
        VStack(spacing: 12) {
          storeInfoCard
          managementCard
          infoCard
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
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
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)

      Spacer()

      Button(action: {}) {
        Image.meatballIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale600)
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)
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

        Button(action: {}) {
          Text("수정")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColor.grayscale300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
      }

      Text(storeName.isEmpty ? "매장명 미설정" : storeName)
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 28) {
        metric(label: "직원", value: "\(employees)명")
        metric(label: "인건비", value: formattedLaborCost)
      }
    }
    .padding(20)
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
        .font(.pretendardCaption2)
        .foregroundColor(AppColor.grayscale500)

      Text(value)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
    }
  }

  private var managementCard: some View {
    VStack(spacing: 0) {
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
      }
      .buttonStyle(.plain)

      Divider()
        .foregroundColor(AppColor.grayscale300)

      HStack {
        Text("알림")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)

        Spacer(minLength: 0)

        Toggle("", isOn: $notificationsEnabled)
          .labelsHidden()
          .tint(AppColor.primaryBlue500)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  private var infoCard: some View {
    VStack(spacing: 0) {
      settingsRow(title: "FAQ")

      Divider()
        .foregroundColor(AppColor.grayscale300)

      settingsRow(title: "이용약관")

      Divider()
        .foregroundColor(AppColor.grayscale300)

      settingsRow(title: "회원탈퇴")
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
}

#Preview {
  HomeView(
    store: Store(initialState: HomeFeature.State()) {
      HomeFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
