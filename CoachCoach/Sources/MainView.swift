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
    
    @State private var strategyDateLabel: String = ""
    @State private var menus: [InsightNeedManagementMenuResponse] = []
    @State private var isLoading: Bool = false
    @State private var loadError: String?
  @State private var selectedStrategyId: Int?
  @State private var selectedStrategyMenuName: String = ""
  @State private var isStrategyDetailPresented: Bool = false
  @State private var isNeedManagementTooltipPresented: Bool = false
  @State private var needManagementTooltipBubbleWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            AppColor.grayscale200.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                NavigationTopBar(onBackTap: { dismiss() },
                                 backgroundColor: .clear)
                ScrollView {
                    Text(strategyDateLabel)
                        .font(.pretendardCaption3)
                        .foregroundColor(AppColor.grayscale700)
                        .padding(.leading, 6)
                        .padding(.trailing, 8)
                        .padding(.bottom, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(AppColor.grayscale300)
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image("WarningIllust", bundle: .main)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 63)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    
                    if let headlineRateText {
                        HStack(spacing: 4) {
                            Text(headlineRateText)
                                .font(.pretendardBody2)
                                .foregroundColor(AppColor.error)
                            
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppColor.error)
                        }
                        .frame(minHeight: 26)
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack(spacing: 6) {
                        Text("관리가 필요한 메뉴")
                            .font(.pretendardSubtitle1)
                            .foregroundColor(AppColor.grayscale700)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isNeedManagementTooltipPresented.toggle()
                            }
                        }) {
                            Image("NeedManagementInfoIcon", bundle: .main)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .top) {
                            if isNeedManagementTooltipPresented {
                                needManagementTooltip
                                    .fixedSize(horizontal: true, vertical: true)
                                    .alignmentGuide(.top) { dimensions in
                                        dimensions[.bottom]
                                    }
                                    .zIndex(10)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                    .frame(minHeight: 20)
                    .frame(maxWidth: .infinity)
                    .zIndex(1)
                    
                    if let loadError {
                        Text(loadError)
                            .font(.pretendardCaption2)
                            .foregroundColor(AppColor.semanticWarningText)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(menus, id: \.strategyId) { menu in
                            menuCard(menu)
                        }
                    }
                    
                    if menus.isEmpty && !isLoading && loadError == nil {
                        Text("표시할 메뉴 데이터가 없어요")
                            .font(.pretendardBody2)
                            .foregroundColor(AppColor.grayscale500)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isStrategyDetailPresented) {
            if let selectedStrategyId {
                DangerStrategyDetailView(
                    strategyId: selectedStrategyId,
                    fallbackMenuName: selectedStrategyMenuName
                )
            } else {
                EmptyView()
            }
        }
        .task {
            await loadData()
        }
    }
    
    private var headlineRateText: String? {
        guard let maxCostRate = menus.map(\.costRate).max() else { return nil }
        return "원가율 \(Int(maxCostRate.rounded()))%"
    }
    
  private var needManagementTooltip: some View {
    VStack(alignment: .center, spacing: 0) {
      Text("원가율이 50%이상인 메뉴를 대상으로\n전략이 매주 일요일 밤 새롭게 생성돼요")
        .font(.pretendardCaption2)
        .foregroundColor(.white)
        .multilineTextAlignment(.leading)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(AppColor.grayscale700)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .background(
          GeometryReader { proxy in
            Color.clear
              .preference(
                key: NeedManagementTooltipWidthPreferenceKey.self,
                value: proxy.size.width
              )
          }
        )
        .offset(x: -(needManagementTooltipBubbleWidth * 0.4))

      NeedManagementTooltipTriangle()
        .fill(AppColor.grayscale700)
        .frame(width: 10, height: 6)
    }
    .onPreferenceChange(NeedManagementTooltipWidthPreferenceKey.self) { width in
      needManagementTooltipBubbleWidth = width
    }
  }
    
    private func menuCard(_ menu: InsightNeedManagementMenuResponse) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(statusText(from: menu.marginGradeCode))
                .font(.pretendardCaption3)
                .foregroundColor(statusTextColor(from: menu.marginGradeCode))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(statusBackgroundColor(from: menu.marginGradeCode))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            Text(menu.menuName)
                .font(.pretendardSubtitle3)
                .frame(minHeight: 26)
                .foregroundColor(AppColor.grayscale900)
                .lineLimit(2)
                .padding(.bottom, 10)
            
            HStack(spacing: 16) {
                metricColumn(title: "원가율", value: formattedPercent(menu.costRate), valueColor: AppColor.error)
                
                Rectangle()
                    .fill(AppColor.grayscale300)
                    .frame(width: 1, height: 30)
                
                metricColumn(title: "마진율", value: formattedPercent(menu.marginRate), valueColor: AppColor.grayscale700)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    selectedStrategyId = menu.strategyId
                    selectedStrategyMenuName = menu.menuName
                    isStrategyDetailPresented = true
                }) {
                    HStack(spacing: 2) {
                        Text("전략 확인")
                            .frame(minHeight: 20)
                            .lineLimit(1)
                            .font(.pretendardCaption3)
                            .foregroundColor(AppColor.primaryBlue500)
                        
                        Image.chevronRightOutlineIcon
                            .renderingMode(.template)
                            .font(.pretendardCTA)
                            .foregroundColor(AppColor.primaryBlue500)
                            .frame(width: 16, height: 16)
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 4)
                    .padding(.vertical, 4)
                    .background(AppColor.primaryBlue100)
                    .clipShape(Capsule(style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func metricColumn(title: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.pretendardCaption3)
                .foregroundColor(AppColor.grayscale500)
            
            Text(value)
                .font(.pretendardSubtitle3)
                .foregroundColor(valueColor)
        }
    }
    
    private func statusText(from marginGradeCode: String) -> String {
        MenuStatus.from(marginGradeCode: marginGradeCode).text
    }
    
    private func statusBackgroundColor(from marginGradeCode: String) -> Color {
        switch MenuStatus.from(marginGradeCode: marginGradeCode) {
        case .danger:
            return AppColor.semanticWarning
        case .warning:
            return AppColor.semanticCaution
        case .safe:
            return AppColor.semanticSafe
        case .normal:
            return AppColor.grayscale200
        }
    }
    
    private func statusTextColor(from marginGradeCode: String) -> Color {
        switch MenuStatus.from(marginGradeCode: marginGradeCode) {
        case .danger:
            return AppColor.semanticWarningText
        case .warning:
            return AppColor.semanticCautionText
        case .safe:
            return AppColor.semanticSafeText
        case .normal:
            return AppColor.grayscale700
        }
    }
    
    private func formattedPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }
    
    private func formattedStrategyDate(_ dateString: String?) -> String {
        guard let dateString, !dateString.isEmpty else { return "기준일 없음" }
        
        let sourceFormatter = DateFormatter()
        sourceFormatter.locale = Locale(identifier: "en_US_POSIX")
        sourceFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = sourceFormatter.date(from: dateString) else {
            return "\(dateString) 기준"
        }
        
        let targetFormatter = DateFormatter()
        targetFormatter.locale = Locale(identifier: "ko_KR")
        targetFormatter.dateFormat = "M월 d일 기준"
        return targetFormatter.string(from: date)
    }
    
    private func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await InsightRepository.liveValue.fetchNeedManagementMenus()
            strategyDateLabel = formattedStrategyDate(response.strategyDate)
            menus = response.menus
            
            if menus.isEmpty {
                loadError = "표시할 주의 메뉴 데이터가 없어요"
            } else {
                loadError = nil
            }
        } catch {
            loadError = "데이터를 불러오지 못했어요"
        }
    }
}

private struct NeedManagementTooltipTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct NeedManagementTooltipWidthPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

private struct DangerStrategyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let strategyId: Int
    let fallbackMenuName: String
    
    @State private var detail: InsightStrategyDetailResponse?
    @State private var isLoading = false
    @State private var loadError: String?
    
    var body: some View {
        ZStack {
            AppColor.grayscale200
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationTopBar(
                    onBackTap: { dismiss() },
                    verticalPadding: 0,
                    backgroundColor: .clear
                )
                
                ScrollView {
                    VStack(spacing: 12) {
                        if let detail {
                            Text("\(detail.month)월 \(detail.weekOfMonth)주차")
                                .font(.pretendardCaption1)
                                .foregroundColor(AppColor.grayscale500)
                            
                            Text(detailTitle(from: detail))
                                .font(.pretendardTitle2)
                                .foregroundColor(AppColor.primaryBlue500)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 4)
                            
                            diagnosisCard(detail)
                            infoCard(icon: Image.aiCoachActionGuideIcon, title: "행동 가이드", text: detail.guide)
                            infoCard(icon: Image.aiCoachExpectedEffectIcon, title: "기대효과", text: detail.expectedEffect)
                        }
                        
                        if let loadError {
                            Text(loadError)
                                .font(.pretendardBody2)
                                .foregroundColor(AppColor.semanticWarningText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadDetail()
        }
    }
    
    private func detailTitle(from detail: InsightStrategyDetailResponse) -> String {
        if !detail.summary.isEmpty {
            return detail.summary
        }
        let menuName = detail.menuName ?? fallbackMenuName
        return "\(menuName) 관리 전략"
    }
    
    private func diagnosisCard(_ detail: InsightStrategyDetailResponse) -> some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(spacing: 8) {
                Image.aiCoachDiagnosisIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text("진단")
                    .font(.pretendardSubtitle3)
                    .foregroundColor(AppColor.grayscale900)
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                Text("\((detail.menuName ?? fallbackMenuName))의 원가율 ")
                    .font(.pretendardBody2)
                    .foregroundColor(AppColor.grayscale900)
                
                Text(formattedCostRate(detail.costRate))
                    .font(.pretendardBody2)
                    .foregroundColor(AppColor.error)
            }
            
            Text(detail.detail.isEmpty ? detail.summary : detail.detail)
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale600)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func infoCard(icon: Image, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.pretendardBody2)
                    .foregroundColor(AppColor.grayscale900)
            }
            
            Text(text)
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale700)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func formattedCostRate(_ costRate: Double?) -> String {
        guard let costRate else { return "-" }
        return String(format: "%.0f%%", costRate)
    }
    
    private func loadDetail() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            detail = try await InsightRepository.liveValue.fetchStrategyDetail(strategyId, "DANGER")
            loadError = nil
        } catch {
            loadError = "전략 상세를 불러오지 못했어요"
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
