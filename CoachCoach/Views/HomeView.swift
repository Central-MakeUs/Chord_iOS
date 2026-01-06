import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var settingsRouter: SettingsRouter
  
  var body: some View {
    NavigationStack(path: $settingsRouter.path) {
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()
        
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            header
            diagnosisBanner
            strategyGuideSection
            profitSummarySection
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
        }
      }
      .navigationDestination(for: SettingsRoute.self) { route in
        switch route {
        case .settings:
          SettingsView()
        case .weeklyGuide:
          WeeklyGuideDetailView()
        case .resolvedHistory:
          ResolvedHistoryView()
        }
      }
    }
  }
  
  private var header: some View {
    HStack {
      Text("코치코치")
        .font(.pretendardTitle1)
        .foregroundStyle(AppColor.primaryBlue500)
      Spacer()
      NavigationLink(value: SettingsRoute.settings) {
        Image.menuRoundedIcon
          .renderingMode(.template)
          .foregroundStyle(AppColor.grayscale700)
      }
    }
  }
  
  private var diagnosisBanner: some View {
    HStack {
      Text("진단이 필요한 메뉴")
        .font(.pretendardBody2)
        .foregroundStyle(AppColor.grayscale100)
      Spacer()
      HStack(spacing: 6) {
        Text("3 개")
          .font(.pretendardSubTitle)
          .foregroundStyle(AppColor.grayscale100)
        Circle()
          .fill(AppColor.grayscale100)
          .frame(width: 6, height: 6)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(AppColor.primaryBlue500)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
  
  private var strategyGuideSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader(title: "전략 가이드", actionTitle: "자세히", route: .weeklyGuide)
      StrategyGuideCard()
    }
  }
  
  private var profitSummarySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("수익 진단")
        .font(.pretendardSubTitle)
        .foregroundStyle(AppColor.grayscale900)
      HStack(spacing: 12) {
        ProfitSummaryCard(
          title: "평균 원가율",
          value: "28.5%",
          description: "안정적"
        )
        ProfitSummaryCard(
          title: "공헌이익율",
          value: "+12%",
          description: "지난주 대비 상승"
        )
      }
    }
  }
}

private struct SectionHeader: View {
  let title: String
  let actionTitle: String
  let route: SettingsRoute
  
  var body: some View {
    HStack {
      Text(title)
        .font(.pretendardSubTitle)
        .foregroundStyle(AppColor.grayscale900)
      Spacer()
      NavigationLink(value: route) {
        HStack(spacing: 0) {
          Text(actionTitle)
            .font(.pretendardCTA)
          Image.chevronRightOutlineIcon
        }
        .font(.pretendardCaption)
        .foregroundStyle(AppColor.grayscale700)
      }
    }
  }
}

private struct StrategyGuideCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      StrategyGuideRow(
        summary: "원가율 35% 유지 가능해요",
        title: "바닐라 라떼",
        action: "판매가 조정"
      )
      StrategyGuideRow(
        summary: "단가가 18% 상승했어요",
        title: "우유",
        action: "대체 브랜드 알아보기"
      )
      StrategyGuideRow(
        summary: "원가율 35% 유지 가능해요",
        title: "레몬티",
        action: "시즌 메뉴로 전환"
      )
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
      VStack(alignment: .leading, spacing: 6) {
        Text(summary)
          .font(.pretendardCaption)
          .foregroundStyle(AppColor.grayscale700)
        HStack(spacing: 6) {
          Text(title)
            .font(.pretendardCTA)
            .foregroundStyle(AppColor.grayscale900)
          Text(action)
            .font(.pretendardCTA)
            .foregroundStyle(AppColor.primaryBlue500)
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
        .foregroundStyle(AppColor.primaryBlue500)
        .padding(6)
        .background(.primaryBlue100)
        .clipShape(RoundedRectangle(cornerRadius: 6))
      Text(value)
        .font(.pretendardTitle1)
        .foregroundStyle(AppColor.grayscale900)
      Text(description)
        .font(.pretendardBody2)
        .foregroundStyle(AppColor.grayscale700)
      Spacer()
        .frame(height: 20)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(
      LinearGradient(
        stops: [
          Gradient.Stop(color: .grayscale100, location: 0.00),
          Gradient.Stop(color: .primaryBlue200, location: 1.00),
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
  HomeView()
    .environmentObject(SettingsRouter())
    .environment(\.colorScheme, .light)
}
