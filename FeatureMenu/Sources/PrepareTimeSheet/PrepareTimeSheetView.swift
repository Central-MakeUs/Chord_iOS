import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct PrepareTimeSheetView: View {
  let store: StoreOf<PrepareTimeSheetFeature>
  let onComplete: (Int, Int) -> Void
  
  public init(
    store: StoreOf<PrepareTimeSheetFeature>,
    onComplete: @escaping (Int, Int) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Capsule()
          .fill(AppColor.grayscale300)
          .frame(width: 60, height: 6)
          .padding(.top, 12)
        
        Text("제조 시간")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)
          .padding(.top, 24)
        
        HStack(spacing: 0) {
          Picker("분", selection: viewStore.binding(
            get: \.draftMinutes,
            send: PrepareTimeSheetFeature.Action.minutesChanged
          )) {
            ForEach(0..<60) { minute in
              Text("\(minute)")
                .font(.pretendardHeadline1)
                .tag(minute)
            }
          }
          .pickerStyle(.wheel)
          .frame(maxWidth: .infinity)
          
          Text("분")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)
          
          Picker("초", selection: viewStore.binding(
            get: \.draftSeconds,
            send: PrepareTimeSheetFeature.Action.secondsChanged
          )) {
            ForEach(0..<60) { second in
              Text("\(second)")
                .font(.pretendardHeadline1)
                .tag(second)
            }
          }
          .pickerStyle(.wheel)
          .frame(maxWidth: .infinity)
          
          Text("초")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        
        Spacer(minLength: 20)
        
        BottomButton(
          title: "완료",
          style: .primary
        ) {
          viewStore.send(.confirmTapped)
          onComplete(viewStore.draftMinutes, viewStore.draftSeconds)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
  }
}

#Preview {
  PrepareTimeSheetView(
    store: Store(
      initialState: PrepareTimeSheetFeature.State(minutes: 1, seconds: 30)
    ) {
      PrepareTimeSheetFeature()
    },
    onComplete: { _, _ in }
  )
  .environment(\.colorScheme, .light)
}
