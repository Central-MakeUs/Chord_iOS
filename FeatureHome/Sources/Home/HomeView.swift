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
      NavigationStack(
        path: viewStore.binding(
          get: \.path,
          send: HomeFeature.Action.pathChanged
        )
      ) {
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
        .navigationDestination(for: HomeRoute.self) { route in
          switch route {
          case .settings:
            SettingsView()
          case .weeklyGuide:
            WeeklyGuideDetailView()
          case .resolvedHistory:
            ResolvedHistoryView()
          }
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
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

private struct SettingsView: View {
  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
    }
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

#Preview {
  HomeView(
    store: Store(initialState: HomeFeature.State()) {
      HomeFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
