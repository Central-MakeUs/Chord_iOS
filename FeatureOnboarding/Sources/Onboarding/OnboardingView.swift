import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnboardingView: View {
  let store: StoreOf<OnboardingFeature>

  public init(store: StoreOf<OnboardingFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 24) {
          topBar(onBack: { viewStore.send(.backTapped) })

          Text("매장 정보를 알려주세요")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)

          content(viewStore: viewStore)

          Spacer(minLength: 0)

          BottomButton(
            title: "확인",
            style: isPrimaryEnabled(step: viewStore.step, storeName: viewStore.storeName, address: viewStore.address) ? .primary : .secondary
          ) {
            viewStore.send(.primaryTapped)
          }
          .disabled(!isPrimaryEnabled(step: viewStore.step, storeName: viewStore.storeName, address: viewStore.address))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isDetailAddressPresented,
          send: OnboardingFeature.Action.detailAddressPresented
        )
      ) {
        OnboardingDetailAddressSheetView(
          store: Store(
            initialState: OnboardingDetailAddressSheetFeature.State(
              draftAddress: viewStore.detailAddress
            )
          ) {
            OnboardingDetailAddressSheetFeature()
          },
          onComplete: { address in
            viewStore.send(.detailAddressChanged(address))
            viewStore.send(.detailAddressPresented(false))
          }
        )
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isStaffCountPresented,
          send: OnboardingFeature.Action.staffCountPresented
        )
      ) {
        OnboardingStaffCountSheetView(
          store: Store(
            initialState: OnboardingStaffCountSheetFeature.State(staffCount: viewStore.staffCount)
          ) {
            OnboardingStaffCountSheetFeature()
          },
          onComplete: { count in
            viewStore.send(.staffCountChanged(count))
            viewStore.send(.staffCountSheetCompleted)
          }
        )
        .presentationDetents([.height(312)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
    }
  }

  private func topBar(onBack: @escaping () -> Void) -> some View {
    HStack {
      Button(action: onBack) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)

      Spacer()
    }
  }

  @ViewBuilder
  private func content(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
    switch viewStore.step {
    case .storeName:
      UnderlinedTextField(
        text: viewStore.binding(
          get: \.storeName,
          send: OnboardingFeature.Action.storeNameChanged
        ),
        title: "매장명",
        placeholder: "예) 코치카페 강남점"
      )
    case .address:
      VStack(alignment: .leading, spacing: 20) {
        UnderlinedTextField(
          text: viewStore.binding(
            get: \.address,
            send: OnboardingFeature.Action.addressChanged
          ),
          title: "매장 주소",
          placeholder: "도로명 주소 입력",
          titleColor: AppColor.primaryBlue500,
          trailingIcon: Image.searchIcon,
          onTrailingTap: { viewStore.send(.detailAddressPresented(true)) }
        )

        UnderlinedValueField(
          title: "매장명",
          value: viewStore.storeName,
          placeholder: "예) 코치카페 강남점"
        )
      }
    case .confirm:
      VStack(alignment: .leading, spacing: 20) {
        UnderlinedValueField(
          title: "상세주소",
          value: viewStore.detailAddress,
          placeholder: "층 / 호수"
        )

        UnderlinedValueField(
          title: "매장 주소",
          value: viewStore.address,
          placeholder: "도로명 주소 입력"
        )

        UnderlinedValueField(
          title: "매장명",
          value: viewStore.storeName,
          placeholder: "예) 코치카페 강남점"
        )
      }
    }
  }

  private func isPrimaryEnabled(step: OnboardingFeature.Step, storeName: String, address: String) -> Bool {
    switch step {
    case .storeName:
      return !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .address:
      return !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .confirm:
      return true
    }
  }
}

private struct UnderlinedValueField: View {
  let title: String
  let value: String
  let placeholder: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale700)

      Text(value.isEmpty ? placeholder : value)
        .font(.pretendardBody2)
        .foregroundColor(value.isEmpty ? AppColor.grayscale400 : AppColor.grayscale900)

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
  }
}

private struct SheetCornerRadiusModifier: ViewModifier {
  let radius: CGFloat

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 16.4, *) {
      content.presentationCornerRadius(radius)
    } else {
      content
    }
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
