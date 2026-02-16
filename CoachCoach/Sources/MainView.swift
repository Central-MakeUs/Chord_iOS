import SwiftUI
import ComposableArchitecture
import CoreCommon
import CoreModels
import DataLayer
import DesignSystem
import FeatureAICoach
import FeatureHome
import FeatureIngredients
import FeatureMenu
import FeatureMenuRegistration

struct MainView: View {
  let store: StoreOf<MainFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack(
        path: viewStore.binding(
          get: \.path,
          send: MainFeature.Action.pathChanged
        )
      ) {
        tabs(viewStore)
          .tint(AppColor.grayscale900)
          .navigationDestination(for: HomeRoute.self) { route in
            homeDestination(route, viewStore: viewStore)
          }
          .navigationDestination(for: MenuRoute.self) { menuDestination($0, viewStore: viewStore) }
          .navigationDestination(for: IngredientsRoute.self) { ingredientsDestination($0) }
      }
      .onAppear {
        viewStore.send(.selectedTabChanged(.home))
      }
    }
  }

  @ViewBuilder
  private func tabs(_ viewStore: ViewStoreOf<MainFeature>) -> some View {
    TabView(
      selection: viewStore.binding(
        get: \.selectedTab,
        send: MainFeature.Action.selectedTabChanged
      )
    ) {
      IfLetStore(store.scope(state: \.home, action: \.home)) { homeStore in
        HomeView(store: homeStore)
      } else: {
        AppRoutePlaceholderView(title: "홈 로딩 중...")
      }
      .tag(AppTab.home)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .home ? Image.homeIconActive : Image.homeIcon)
            .renderingMode(.original)
          Text("홈")
        }
      }

      IfLetStore(store.scope(state: \.menu, action: \.menu)) { menuStore in
        MenuView(store: menuStore)
      } else: {
        AppRoutePlaceholderView(title: "메뉴 로딩 중...")
      }
      .tag(AppTab.menu)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .menu ? Image.menuIconActive : Image.menuIcon)
            .renderingMode(.original)
          Text("메뉴")
        }
      }

      IfLetStore(store.scope(state: \.ingredients, action: \.ingredients)) { ingredientsStore in
        IngredientsView(store: ingredientsStore)
      } else: {
        AppRoutePlaceholderView(title: "재료 로딩 중...")
      }
      .tag(AppTab.ingredients)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .ingredients ? Image.meterialIconActive : Image.meterialIcon)
            .renderingMode(.original)
          Text("재료")
        }
      }

      IfLetStore(store.scope(state: \.aiCoach, action: \.aiCoach)) { aiCoachStore in
        AICoachView(store: aiCoachStore)
      } else: {
        AppRoutePlaceholderView(title: "AI코치 로딩 중...")
      }
      .tag(AppTab.aiCoach)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .aiCoach ? Image.aiCoachIconActive : Image.aiCoachIcon)
            .renderingMode(.original)
          Text("AI코치")
        }
      }
    }
    .toolbarBackground(.visible, for: .tabBar)
    .toolbarBackground(Color.white, for: .tabBar)
  }

  @ViewBuilder
  private func homeDestination(_ route: HomeRoute, viewStore: ViewStoreOf<MainFeature>) -> some View {
    switch route {
    case .settings:
      HomeSettingsView(onLogoutConfirmed: {
        viewStore.send(.logoutTapped)
      }, onWithdrawalConfirmed: {
        viewStore.send(.withdrawalTapped)
      })
    case .weeklyGuide:
      WeeklyGuideDetailView()
    case .resolvedHistory:
      ResolvedHistoryView()
    }
  }

  @ViewBuilder
  private func menuDestination(_ route: MenuRoute, viewStore: ViewStoreOf<MainFeature>) -> some View {
    switch route {
    case let .detail(item):
      MenuDetailView(
        store: Store(initialState: MenuDetailFeature.State(item: item)) {
          MenuDetailFeature()
        }
      )
    case .add:
      MenuRegistrationView(
        store: Store(initialState: MenuRegistrationFeature.State()) {
          MenuRegistrationFeature()
        },
        onMenuCreated: {
          viewStore.send(.menu(.popToRoot))
        }
      )
    case let .edit(item):
      MenuEditView(
        store: Store(initialState: MenuEditFeature.State(item: item)) {
          MenuEditFeature()
        }
      )
    case let .ingredients(menuId, menuName, ingredients):
      MenuIngredientsView(
        store: Store(
          initialState: MenuIngredientsFeature.State(
            menuId: menuId,
            menuName: menuName,
            ingredients: ingredients
          )
        ) {
          MenuIngredientsFeature()
        }
      )
    }
  }

  @ViewBuilder
  private func ingredientsDestination(_ route: IngredientsRoute) -> some View {
    switch route {
    case let .detail(item):
      IngredientDetailView(
        store: Store(initialState: IngredientDetailFeature.State(item: item)) {
          IngredientDetailFeature()
        }
      )
    case .add:
      EmptyView()
    case .search:
      IngredientSearchView(
        store: Store(initialState: IngredientSearchFeature.State()) {
          IngredientSearchFeature()
        }
      )
    }
  }
}

private struct WeeklyGuideDetailView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var weekLabel: String = ""
  @State private var strategyTitle: String = "주의메뉴 관리 전략"
  @State private var cautionMenus: [(name: String, price: String)] = []
  @State private var guideText: String = "위 메뉴중 1개를 '안전 단계'로 옮기는 걸\n목표 해보세요."
  @State private var expectedEffectText: String = "위 메뉴중 1개를 '안전 단계'로 옮기는 걸\n목표 해보세요."
  @State private var isLoading: Bool = false
  @State private var loadError: String?

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        HStack {
          Button(action: { dismiss() }) {
            Image.arrowLeftIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale900)
              .frame(width: 24, height: 24)
          }
          .buttonStyle(.plain)

          Spacer()
        }

        VStack(alignment: .leading, spacing: 8) {
          Text(weekLabel.isEmpty ? currentWeekLabel() : weekLabel)
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.grayscale600)

          Text(strategyTitle)
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.primaryBlue500)
        }

        VStack(alignment: .leading, spacing: 12) {
          sectionTitle(icon: "exclamationmark.triangle.fill", iconColor: AppColor.semanticWarningText, title: "현재 주의 메뉴")

          Text("이 메뉴들은 원가율이 35% 이상으로,\n판매는 되지만, 남는 금액이 평균보다 낮은 구조예요.")
            .font(.pretendardBody1)
            .foregroundColor(AppColor.grayscale900)
            .lineSpacing(4)

          if let loadError {
            Text(loadError)
              .font(.pretendardCaption2)
              .foregroundColor(AppColor.semanticWarningText)
          }

          VStack(spacing: 0) {
            ForEach(Array(cautionMenus.enumerated()), id: \.offset) { index, item in
              HStack(spacing: 12) {
                Text("\(index + 1)")
                  .font(.pretendardSubtitle2)
                  .foregroundColor(AppColor.primaryBlue500)
                  .frame(width: 26, height: 26)
                  .background(
                    Circle().fill(AppColor.primaryBlue200)
                  )

                Text(item.name)
                  .font(.pretendardSubtitle1)
                  .foregroundColor(AppColor.grayscale700)

                Spacer()

                Text(item.price)
                  .font(.pretendardTitle2)
                  .foregroundColor(AppColor.grayscale600)
              }
              .padding(.vertical, 10)

              if index < cautionMenus.count - 1 {
                Divider().background(AppColor.grayscale200)
              }
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }

        VStack(alignment: .leading, spacing: 12) {
          sectionTitle(icon: "exclamationmark.triangle.fill", iconColor: AppColor.semanticWarningText, title: "이렇게 해보세요")

          guideCard(text: guideText)
        }

        VStack(alignment: .leading, spacing: 12) {
          sectionTitle(icon: "sparkles", iconColor: AppColor.primaryBlue500, title: "기대효과")

          guideCard(text: expectedEffectText)
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 12)
      .padding(.bottom, 24)
    }
    .overlay {
      if isLoading {
        ProgressView()
      }
    }
    .background(AppColor.grayscale200.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .task {
      await loadData()
    }
  }

  private func sectionTitle(icon: String, iconColor: Color, title: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(iconColor)

      Text(title)
        .font(.pretendardTitle2)
        .foregroundColor(AppColor.grayscale900)
    }
  }

  private func guideCard(text: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("행동 가이드")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)

      HStack(alignment: .top, spacing: 10) {
        Circle()
          .fill(AppColor.grayscale300)
          .frame(width: 8, height: 8)
          .padding(.top, 8)

        Text(text)
          .font(.pretendardBody1)
          .foregroundColor(AppColor.grayscale900)
          .lineSpacing(4)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }

  private func currentWeekLabel() -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "ko_KR")
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    let now = Date()
    let month = calendar.component(.month, from: now)
    let week = calendar.component(.weekOfMonth, from: now)
    return "\(month)월 \(week)주차"
  }

  private func titleForStrategyType(_ type: String) -> String {
    switch type {
    case "DANGER": return "주의메뉴 관리 전략"
    case "CAUTION": return "주의메뉴 점검 전략"
    case "HIGH_MARGIN": return "고마진 메뉴 강화 전략"
    default: return "주의메뉴 관리 전략"
    }
  }

  private func currentYearMonthWeek() -> (Int, Int, Int) {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "ko_KR")
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    let now = Date()
    let year = calendar.component(.year, from: now)
    let month = calendar.component(.month, from: now)
    let week = calendar.component(.weekOfMonth, from: now)
    return (year, month, week)
  }

  private func loadData() async {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }

    let (year, month, week) = currentYearMonthWeek()

    async let menusTask = MenuRepository.liveValue.fetchMenuItems(nil)
    async let weeklyTask = InsightRepository.liveValue.fetchWeeklyStrategies(year, month, week)

    do {
      let menus = try await menusTask
      let weekly = try await weeklyTask

      weekLabel = "\(month)월 \(week)주차"

      if let first = weekly.first {
        strategyTitle = titleForStrategyType(first.type)
        guideText = first.detail ?? ""
        expectedEffectText = first.summary ?? ""
      }

      let caution = menus.filter { $0.status == .warning }
      let danger = menus.filter { $0.status == .danger }
      let source = caution.isEmpty ? danger : caution

      cautionMenus = source.prefix(5).map { menu in
        (name: menu.name, price: menu.price)
      }

      if cautionMenus.isEmpty {
        loadError = "표시할 주의 메뉴 데이터가 없어요"
      } else {
        loadError = nil
      }
    } catch {
      loadError = "데이터를 불러오지 못했어요"
    }
  }
}

private struct ResolvedHistoryView: View {
  var body: some View {
    ZStack {
      AppColor.grayscale100.ignoresSafeArea()
    }
  }
}

private struct AppRoutePlaceholderView: View {
  let title: String

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
      Text(title)
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.grayscale900)
    }
  }
}

#Preview {
  MainView(
    store: Store(initialState: MainFeature.State()) {
      MainFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
