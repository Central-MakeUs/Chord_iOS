import SwiftUI

struct OnboardingView: View {
  enum Step {
    case storeName
    case address
    case confirm
  }

  @State private var step: Step = .storeName
  @State private var storeName: String = ""
  @State private var address: String = ""
  @State private var detailAddress: String = ""
  @State private var staffCount: Int = 3
  @State private var isDetailAddressPresented = false
  @State private var isStaffCountPresented = false

  let onFinish: () -> Void

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 24) {
        topBar

        Text("매장 정보를 알려주세요")
          .font(.pretendardHeadline1)
          .foregroundColor(AppColor.grayscale900)

        content

        Spacer(minLength: 0)

        BottomButton(title: "확인", style: isPrimaryEnabled ? .primary : .secondary) {
          handlePrimaryAction()
        }
        .disabled(!isPrimaryEnabled)
      }
      .padding(.horizontal, 20)
      .padding(.top, 12)
      .padding(.bottom, 24)
    }
    .sheet(isPresented: $isDetailAddressPresented) {
      OnboardingDetailAddressSheetView(detailAddress: $detailAddress)
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
    }
    .sheet(isPresented: $isStaffCountPresented) {
      OnboardingStaffCountSheetView(staffCount: $staffCount) {
        onFinish()
      }
      .presentationDetents([.height(312)])
      .presentationDragIndicator(.hidden)
      .modifier(SheetCornerRadiusModifier(radius: 24))
    }
  }

  private var topBar: some View {
    HStack {
      Button(action: handleBack) {
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
  private var content: some View {
    switch step {
    case .storeName:
      UnderlinedTextField(
        text: $storeName,
        title: "매장명",
        placeholder: "예) 코치카페 강남점"
      )
    case .address:
      VStack(alignment: .leading, spacing: 20) {
        UnderlinedTextField(
          text: $address,
          title: "매장 주소",
          placeholder: "도로명 주소 입력",
          titleColor: AppColor.primaryBlue500,
          trailingIcon: Image.searchIcon,
          onTrailingTap: { isDetailAddressPresented = true }
        )

        UnderlinedValueField(
          title: "매장명",
          value: storeName,
          placeholder: "예) 코치카페 강남점"
        )
      }
    case .confirm:
      VStack(alignment: .leading, spacing: 20) {
        UnderlinedValueField(
          title: "상세주소",
          value: detailAddress,
          placeholder: "층 / 호수"
        )

        UnderlinedValueField(
          title: "매장 주소",
          value: address,
          placeholder: "도로명 주소 입력"
        )

        UnderlinedValueField(
          title: "매장명",
          value: storeName,
          placeholder: "예) 코치카페 강남점"
        )
      }
    }
  }

  private var isPrimaryEnabled: Bool {
    switch step {
    case .storeName:
      return !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .address:
      return !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .confirm:
      return true
    }
  }

  private func handlePrimaryAction() {
    switch step {
    case .storeName:
      step = .address
    case .address:
      step = .confirm
    case .confirm:
      isStaffCountPresented = true
    }
  }

  private func handleBack() {
    switch step {
    case .storeName:
      break
    case .address:
      step = .storeName
    case .confirm:
      step = .address
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
  OnboardingView {}
    .environment(\.colorScheme, .light)
}
