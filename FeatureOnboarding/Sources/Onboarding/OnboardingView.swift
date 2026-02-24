import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnboardingView: View {
  let store: StoreOf<OnboardingFeature>
  @State private var isLaborCostFocused = false
  @State private var showLaborCostTooltip = false

  public init(store: StoreOf<OnboardingFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.white.ignoresSafeArea()

        switch viewStore.step {
        case .storeName, .storeOperation:
          formBody(viewStore: viewStore)
            .transition(.opacity)

        case .completion:
          completionView(viewStore: viewStore)
            .transition(.opacity)

        case .menuPrompt:
          menuPromptView(viewStore: viewStore)
            .transition(.asymmetric(
              insertion: .move(edge: .trailing).combined(with: .opacity),
              removal: .opacity
            ))
        }
      }
      .animation(.easeInOut(duration: 0.4), value: viewStore.step)
    }
  }

  private func formBody(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(spacing: 0) {
      NavigationTopBar(onBackTap: { viewStore.send(.backTapped) })

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          content(viewStore: viewStore)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
      }

      BottomButton(
        title: "다음",
        style: isPrimaryEnabled(viewStore: viewStore) ? .primary : .secondary
      ) {
        viewStore.send(.primaryTapped)
      }
      .disabled(!isPrimaryEnabled(viewStore: viewStore))
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
  }

  private func completionView(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(spacing: 0) {
      Spacer()

      VStack(spacing: 24) {
        ImgComplete()

        Text("매장 설정이 완료됐어요")
          .font(.pretendardHeadline1)
          .foregroundColor(AppColor.primaryBlue500)
      }

      Spacer()

      VStack(spacing: 0) {
        summaryRow(label: "매장명", value: viewStore.storeName)
        summaryRow(label: "직원수", value: viewStore.state.staffCountDisplay)
        summaryRow(label: "인건비", value: viewStore.state.formattedLaborCost)
      }
      .padding(.vertical, 4)
      .background(AppColor.primaryBlue100)
      .cornerRadius(12)
      .padding(.horizontal, 40)

      Spacer()
        .frame(height: 80)
    }
  }

  private func summaryRow(label: String, value: String) -> some View {
    HStack {
      Text(label)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale600)
        .frame(width: 60, alignment: .leading)

      Text(value)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)

      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }

  private func menuPromptView(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(spacing: 0) {
      Spacer()

      VStack(spacing: 24) {
        ImgCount()

        VStack(spacing: 8) {
          Text("메뉴를 등록해주시면")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)

          Text("원가와 마진을 계산해드릴게요")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)
        }
        .multilineTextAlignment(.center)
      }

      Spacer()

      BottomButton(title: "메뉴 등록 시작하기", style: .primary) {
        viewStore.send(.menuRegistrationTapped)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 34)
    }
  }

  @ViewBuilder
  private func content(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    switch viewStore.step {
    case .storeName:
      storeNameContent(viewStore: viewStore)
    case .storeOperation:
      storeOperationContent(viewStore: viewStore)
    case .completion, .menuPrompt:
      EmptyView()
    }
  }

  private func storeNameContent(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(alignment: .leading, spacing: 24) {
      Text("매장 정보를 알려주세요")
        .font(.pretendardHeadline1)
        .foregroundColor(AppColor.grayscale900)

      UnderlinedTextField(
        text: viewStore.binding(
          get: \.storeName,
          send: OnboardingFeature.Action.storeNameChanged
        ),
        title: "매장명",
        placeholder: "예) 코치카페 강남점"
      )
    }
  }

  private func storeOperationContent(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(alignment: .leading, spacing: 24) {
      Text("매장 운영 정보를 알려주세요")
        .font(.pretendardHeadline1)
        .foregroundColor(AppColor.grayscale900)

      staffCountSection(viewStore: viewStore)

      laborCostSection(viewStore: viewStore)
    }
  }

  private func staffCountSection(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      UnderlinedTextField(
        text: viewStore.binding(
          get: \.staffCount,
          send: OnboardingFeature.Action.staffCountChanged
        ),
        title: "직원수",
        placeholder: "사장님을 제외한 직원수 입력",
        keyboardType: .numberPad
      )

      checkboxRow(
        isChecked: viewStore.isSoloWorker,
        label: "사장님 혼자 근무중이신가요?"
      ) {
        viewStore.send(.isSoloWorkerToggled)
      }
    }
  }

  private func laborCostSection(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      laborCostField(viewStore: viewStore)

      checkboxRow(
        isChecked: viewStore.includeWeeklyAllowance,
        label: "주휴수당 포함"
      ) {
        viewStore.send(.includeWeeklyAllowanceToggled)
      }

      minimumWageInfoBox
    }
  }

  private func laborCostField(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      VStack(alignment: .leading, spacing: 0) {
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
      }

      if isLaborCostFocused {
        TextField(
          "",
          text: viewStore.binding(
            get: \.laborCost,
            send: OnboardingFeature.Action.laborCostChanged
          ),
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
        Text(formattedLaborCost(viewStore.laborCost))
          .font(.pretendardBody2)
          .foregroundColor(
            viewStore.laborCost.isEmpty ? AppColor.grayscale400 : AppColor.grayscale900
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
    guard let number = Int(cleaned) else { return value }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let formatted = formatter.string(from: NSNumber(value: number)) ?? value
    return "\(formatted)원"
  }

  private func checkboxRow(isChecked: Bool, label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 8) {
        OnboardingCheckbox(isChecked: isChecked)

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

      Triangle()
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

  private func isPrimaryEnabled(viewStore: ViewStoreOf<OnboardingFeature>) -> Bool {
    switch viewStore.step {
    case .storeName:
      return !viewStore.storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .storeOperation:
      return true
    case .completion, .menuPrompt:
      return false
    }
  }
}

private struct OnboardingCheckbox: View {
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

      CheckmarkShape()
        .fill(isChecked ? Color.white : Color(red: 0.788, green: 0.82, blue: 0.871))
    }
    .frame(width: 18, height: 18)
  }
}

private struct CheckmarkShape: Shape {
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

private struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.closeSubpath()
    return path
  }
}

#Preview {
  OnboardingView(
    store: Store(initialState: OnboardingFeature.State()) {
      OnboardingFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
