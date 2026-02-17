import SwiftUI
import ComposableArchitecture
import Foundation
import DesignSystem

public struct AICoachView: View {
    let store: StoreOf<AICoachFeature>
    
    public init(store: StoreOf<AICoachFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(alignment: .leading, spacing: 28) {
                    recommendedSection(viewStore: viewStore)
                    historySection(viewStore: viewStore)
                }
                .padding(.top, 12)
                .background(AppColor.grayscale200.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
                
                if viewStore.isLoading && viewStore.recommendedStrategies.isEmpty && viewStore.strategyHistory.isEmpty {
                    ProgressView()
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationDestination(
                isPresented: viewStore.binding(
                    get: \.isDetailSheetPresented,
                    send: AICoachFeature.Action.detailSheetPresentedChanged
                )
            ) {
                if let detail = viewStore.selectedDetail {
                    StrategyDetailView(detail: detail) {
                        viewStore.send(.detailExecuteTapped)
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .toolbar(.hidden, for: .tabBar)
                } else {
                    EmptyView()
                }
            }
            .navigationDestination(
                isPresented: viewStore.binding(
                    get: \.isCompletionResultPresented,
                    send: AICoachFeature.Action.completionResultPresentedChanged
                )
            ) {
                if let result = viewStore.completionResult {
                    StrategyCompletionResultView(result: result) {
                        viewStore.send(.completionResultPresentedChanged(false))
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .toolbar(.hidden, for: .tabBar)
                } else {
                    EmptyView()
                }
            }
            .toastBanner(
                isPresented: viewStore.binding(
                    get: \.showToast,
                    send: AICoachFeature.Action.showToastChanged
                ),
                message: viewStore.toastMessage
            )
        }
    }
    
    private func recommendedSection(viewStore: ViewStoreOf<AICoachFeature>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번주 추천 전략")
                .font(.pretendardHeadline2)
                .foregroundColor(AppColor.grayscale900)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            
            if viewStore.recommendedStrategies.isEmpty {
                VStack(spacing: 6) {
                    Text("이번 주 추천 전략이 없어요")
                        .font(.pretendardSubtitle2)
                        .foregroundColor(AppColor.grayscale700)
                    Text("데이터가 쌓이면 추천 전략이 보여요")
                        .font(.pretendardBody2)
                        .foregroundColor(AppColor.grayscale500)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewStore.recommendedStrategies) { strategy in
                            Button(action: { viewStore.send(.strategyTapped(strategy.id)) }) {
                                RecommendedStrategyCard(strategy: strategy)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
        }
    }
    
    private func historySection(viewStore: ViewStoreOf<AICoachFeature>) -> some View {
        VStack(spacing: 0) {
            monthNavigationHeader(viewStore: viewStore)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            
            ScrollView {
                if viewStore.strategyHistory.isEmpty {
                    VStack(spacing: 6) {
                        Text("아직 실행된 전략이 없어요")
                            .font(.pretendardCaption4)
                            .foregroundColor(AppColor.grayscale500)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 0) {
                        ForEach(viewStore.strategyHistory) { item in
                            Button(action: { viewStore.send(.historyTapped(item.id)) }) {
                                StrategyHistoryRow(item: item)
                            }
                            .buttonStyle(.plain)
                            
                            if item.id != viewStore.strategyHistory.last?.id {
                                Divider()
                                    .background(AppColor.grayscale200)
                                    .padding(.leading, 20)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .background(Color.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                topTrailingRadius: 24
            )
        )
        .padding(.horizontal, 20)
    }
    
    private func monthNavigationHeader(viewStore: ViewStoreOf<AICoachFeature>) -> some View {
        HStack {
            HStack(spacing: 8) {
                Button(action: { viewStore.send(.previousMonthTapped) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColor.grayscale700)
                }
                
                Text(viewStore.monthDisplayText)
                    .font(.pretendardSubtitle3)
                    .foregroundColor(AppColor.grayscale900)
                
                Button(action: { viewStore.send(.nextMonthTapped) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColor.grayscale700)
                }
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Button(action: { viewStore.send(.filterSelected(.completed)) }) {
                    Text(StrategyFilter.completed.displayText)
                        .font(.pretendardCaption4)
                        .foregroundColor(viewStore.selectedFilter == .completed ? AppColor.grayscale900 : AppColor.grayscale500)
                        .underline(
                            viewStore.selectedFilter == .completed,
                            color: viewStore.selectedFilter == .completed ? AppColor.grayscale900 : AppColor.grayscale500
                        )
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
                
                Rectangle()
                    .fill(AppColor.grayscale300)
                    .frame(width: 1, height: 13)
                
                Button(action: { viewStore.send(.filterSelected(.incomplete)) }) {
                    Text(StrategyFilter.incomplete.displayText)
                        .font(.pretendardCaption4)
                        .foregroundColor(viewStore.selectedFilter == .incomplete ? AppColor.grayscale900 : AppColor.grayscale500)
                        .underline(
                            viewStore.selectedFilter == .incomplete,
                            color: viewStore.selectedFilter == .incomplete ? AppColor.grayscale900 : AppColor.grayscale500
                        )
                        .padding(.leading, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct RecommendedStrategyCard: View {
    let strategy: RecommendedStrategy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 6) {
                if strategy.status != .completed {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                }
                
                Text(strategy.status.displayText)
                    .font(.pretendardCTA)
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(strategy.title)
                    .frame(minHeight: 26)
                    .font(.pretendardSubtitle3)
                    .foregroundColor(AppColor.grayscale900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(strategy.description)
                    .frame(minHeight: 20)
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.grayscale600)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .layoutPriority(1)
            
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 200, height: 160, alignment: .topLeading)
        .background(AppColor.grayscale100)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColor.grayscale300.opacity(0.35), lineWidth: 0.5)
        )
    }
    
    private var statusColor: Color {
        switch strategy.status {
        case .inProgress: return AppColor.primaryBlue500
        case .completed: return AppColor.grayscale500
        case .notStarted: return AppColor.grayscale500
        }
    }
}

private struct StrategyHistoryRow: View {
    let item: StrategyHistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.weekLabel)
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.grayscale500)
                
                Text(item.title)
                    .font(.pretendardBody1)
                    .foregroundColor(AppColor.grayscale900)
                
                Text(item.description)
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.primaryBlue500)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

private struct StrategyCompletionResultView: View {
    let result: StrategyCompletionResult
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            AppColor.grayscale200
                .ignoresSafeArea()

            VStack(spacing: 0) {
                NavigationTopBar(
                    onBackTap: {
                        onConfirm()
                    },
                    verticalPadding: 0,
                    backgroundColor: .clear
                )
                .padding(.top, 12)

                ScrollView {
                    VStack(spacing: 28) {
                        Text("전략 실행이 완료됐어요")
                            .font(.pretendardTitle2)
                            .foregroundStyle(titleGradient)
                            .multilineTextAlignment(.center)

                        Text(bodyText)
                            .font(.pretendardBody1)
                            .foregroundColor(AppColor.grayscale700)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        completionIllustration
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
                

                BottomButton(title: "확인", style: .primary) {
                    onConfirm()
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var titleGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColor.primaryBlue500,
                Color(red: 122.0 / 255.0, green: 54.0 / 255.0, blue: 245.0 / 255.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var isHighMargin: Bool {
        result.strategyType == "HIGH_MARGIN"
    }

    private var bodyText: String {
        if let completionPhrase = result.completionPhrase?.trimmingCharacters(in: .whitespacesAndNewlines),
           !completionPhrase.isEmpty {
            return completionPhrase
        }

        if isHighMargin {
            return "고마진 메뉴의 판매 비중이 높아지면\n더 빠른 순수익이 쌓이고,\n카페 전체 수익구조가 좋아져요"
        }

        return "좋은 판단이에요!\n이 조치로 우리 카페의 수익이 증가했어요"
    }

    private var completionIllustration: some View {
        Image.strategyCompletionGraphic
            .resizable()
            .scaledToFit()
            .frame(width: 220, height: 220)
            .frame(maxWidth: .infinity)
    }
}

private struct StrategyDetailView: View {
    let detail: StrategyDetailItem
    let onExecute: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
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
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                ScrollView {
                    VStack(spacing: 12) {

                        Text(detail.weekLabel)
                            .font(.pretendardCaption1)
                            .foregroundColor(AppColor.grayscale500)

                        if detail.status == .completed {
                            HStack(spacing: 4) {
                                Text("실행완료")
                                    .font(.pretendardCaption1)
                                    .foregroundColor(.white)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(completedBadgeColor)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }

                        titleSection
                        diagnosisCard
                        infoCard(icon: Image.aiCoachActionGuideIcon, title: "행동 가이드", text: detail.guide)
                        infoCard(icon: Image.aiCoachExpectedEffectIcon, title: "기대효과", text: detail.expectedEffect)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
                
                BottomButton(
                    title: executeButtonTitle,
                    style: isExecutable ? .primary : .secondary
                ) {
                    onExecute()
                }
                .disabled(!isExecutable)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var titleSection: some View {
        Text(detail.title)
            .font(.pretendardTitle2)
            .foregroundStyle(titleGradient)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var titleGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColor.primaryBlue500,
                Color(red: 122.0 / 255.0, green: 54.0 / 255.0, blue: 245.0 / 255.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var diagnosisCard: some View {
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
            
            if detail.type == "HIGH_MARGIN" {
                let displayMenuNames = menuNames.isEmpty ? hardcodedMenuNamesForTest : menuNames

                HStack(spacing: 4) {
                    Text("현재 \(strategyTypeLabel) 메뉴")
                        .font(.pretendardCaption1)
                        .foregroundColor(AppColor.grayscale900)
                    
                    Text("\(displayMenuNames.count)개")
                        .font(.pretendardCaption1)
                        .foregroundColor(AppColor.primaryBlue500)
                    
                    Spacer()
                }
                
                if !displayMenuNames.isEmpty {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 96), spacing: 4)],
                        alignment: .center,
                        spacing: 8
                    ) {
                        ForEach(Array(displayMenuNames.enumerated()), id: \.offset) { _, name in
                            Text(name)
                                .frame(height: 20)
                                .font(.pretendardCaption3)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .background(AppColor.primaryBlue500)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                HStack(spacing: 0) {
                    Text("\(primaryMenuName)의 원가율 ")
                        .font(.pretendardBody2)
                        .foregroundColor(AppColor.grayscale900)
                    
                    Text(formattedCostRate)
                        .font(.pretendardBody2)
                        .foregroundColor(AppColor.error)
                }
            }
            
            Text(diagnosisDescription)
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
    
    private var strategyTypeLabel: String {
        switch detail.type {
        case "DANGER":
            return "위험"
        case "CAUTION":
            return "주의"
        case "HIGH_MARGIN":
            return "고마진"
        default:
            return "전략"
        }
    }
    
    private var menuNames: [String] {
        detail.menuText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private var primaryMenuName: String {
        menuNames.first ?? "해당 메뉴"
    }

    private var hardcodedMenuNamesForTest: [String] {
#if DEBUG
        ["카페라떼", "아메리카노", "고구마 케이크", "딸기 버블티", "버블티"]
#else
        []
#endif
    }
    
    private var formattedCostRate: String {
        guard let costRate = detail.costRate else { return "-" }
        return String(format: "%.0f%%", costRate)
    }
    
    private var diagnosisDescription: String {
        detail.detail.isEmpty ? detail.summary : detail.detail
    }
    
    private var isExecutable: Bool {
        detail.status != .completed
    }

    private var executeButtonTitle: String {
        switch detail.status {
        case .notStarted:
            return "전략 실행하기"
        case .inProgress, .completed:
            return "실행 완료"
        }
    }

    private var completedBadgeColor: Color {
        Color(red: 122.0 / 255.0, green: 54.0 / 255.0, blue: 245.0 / 255.0)
    }
}

#Preview {
    AICoachView(
        store: Store(initialState: AICoachFeature.State()) {
            AICoachFeature()
        }
    )
    .environment(\.colorScheme, .light)
}
