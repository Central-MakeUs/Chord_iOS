import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct AICoachView: View {
  let store: StoreOf<AICoachFeature>

  public init(store: StoreOf<AICoachFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 24) {
        recommendedSection(strategies: viewStore.recommendedStrategies)
        
        historySection(viewStore: viewStore)
      }
      .padding(.top, 12)
      .background(AppColor.primaryBlue100.ignoresSafeArea())
      .toolbar(.hidden, for: .navigationBar)
    }
  }
  
  private func recommendedSection(strategies: [RecommendedStrategy]) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("이번주 추천 전략")
        .font(.pretendardHeadline2)
        .foregroundColor(AppColor.grayscale900)
        .padding(.horizontal, 20)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(strategies) { strategy in
            RecommendedStrategyCard(strategy: strategy)
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }
  
  private func historySection(viewStore: ViewStoreOf<AICoachFeature>) -> some View {
    VStack(spacing: 0) {
      monthNavigationHeader(viewStore: viewStore)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
      
      ScrollView {
        VStack(spacing: 0) {
          ForEach(viewStore.strategyHistory) { item in
            StrategyHistoryRow(item: item)
            
            if item.id != viewStore.strategyHistory.last?.id {
              Divider()
                .background(AppColor.grayscale200)
                .padding(.leading, 92)
            }
          }
        }
      }
      .background(Color.white)
      .clipShape(
        UnevenRoundedRectangle(
          topLeadingRadius: 24,
          topTrailingRadius: 24
        )
      )
    }
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
      
      HStack(spacing: 16) {
        ForEach(StrategyFilter.allCases, id: \.self) { filter in
          Button(action: { viewStore.send(.filterSelected(filter)) }) {
            Text(filter.displayText)
              .font(.pretendardBody2)
              .foregroundColor(viewStore.selectedFilter == filter ? AppColor.grayscale900 : AppColor.grayscale500)
          }
        }
      }
    }
  }
}

private struct RecommendedStrategyCard: View {
  let strategy: RecommendedStrategy
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 6) {
        if strategy.status == .inProgress {
          Circle()
            .fill(AppColor.primaryBlue500)
            .frame(width: 8, height: 8)
        }
        
        Text(strategy.status.displayText)
          .font(.pretendardCaption2)
          .foregroundColor(strategy.status == .inProgress ? AppColor.primaryBlue500 : AppColor.grayscale500)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(strategy.title)
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        
        Text(strategy.description)
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale600)
          .lineLimit(2)
      }
    }
    .padding(16)
    .frame(width: 160, alignment: .topLeading)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColor.grayscale200, lineWidth: 1)
    )
  }
}

private struct StrategyHistoryRow: View {
  let item: StrategyHistoryItem
  
  var body: some View {
    HStack(spacing: 16) {
      RoundedRectangle(cornerRadius: 8)
        .fill(AppColor.grayscale200)
        .frame(width: 56, height: 56)
      
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

#Preview {
  AICoachView(
    store: Store(initialState: AICoachFeature.State()) {
      AICoachFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
