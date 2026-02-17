import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SignUpView: View {
    @Bindable var store: StoreOf<SignUpFeature>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<SignUpFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            switch store.step {
            case .form:
                formView
            case .complete:
                SignUpCompleteView()
            }
        }
        .onChange(of: store.step) { _, newStep in
            if newStep == .complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        }
    }
    
    private var formView: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    userIdSection
                    passwordSection
                    passwordConfirmSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            
            Spacer()
            
            BottomButton(
                title: "가입하기",
                style: store.isFormValid ? .primary : .secondary
            ) {
                store.send(.signUpTapped)
            }
            .disabled(!store.isFormValid)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(
            isPresented: Binding(
                get: { store.isTermsSheetPresented },
                set: { isPresented in
                    if !isPresented {
                        store.send(.termsSheetDismissed)
                    }
                }
            )
        ) {
            TermsAgreementBottomSheet(
                isAllAgreed: store.isAllTermsAgreed,
                isServiceTermsAgreed: store.isServiceTermsAgreed,
                isPrivacyTermsAgreed: store.isPrivacyTermsAgreed,
                onToggleAll: { store.send(.toggleAllTermsAgreement) },
                onToggleService: { store.send(.toggleServiceTermsAgreement) },
                onTogglePrivacy: { store.send(.togglePrivacyTermsAgreement) },
                onConfirm: { store.send(.termsAgreeConfirmTapped) }
            )
            .presentationDetents([.height(355)])
            .presentationCornerRadius(24)
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.white)
        }
        .coachCoachAlert(
            isPresented: $store.isErrorAlertPresented,
            title: store.errorMessage,
            content: "",
            alertType: .oneButton,
            rightButtonTitle: "확인",
            rightButtonAction: {
                store.send(.errorAlertDismissed)
            }
        )
    }
    
    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColor.grayscale900)
            }
            
            Spacer()
            
            Text("회원가입")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale900)
            
            Spacer()
            
            Color.clear
                .frame(width: 20, height: 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var userIdSection: some View {
        UnderlinedTextField(
            text: Binding(
                get: { store.userId },
                set: { store.send(.userIdChanged($0)) }
            ),
            title: "아이디",
            placeholder: "아이디 입력",
            errorMessage: store.userIdError,
            showFocusHighlight: false
        )
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("비밀번호")
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale700)
            
            HStack {
                Group {
                    if store.isPasswordVisible {
                        TextField(
                            "",
                            text: $store.password,
                            prompt: Text("비밀번호 입력")
                                .font(.pretendardSubtitle2)
                                .foregroundColor(AppColor.grayscale500)
                        )
                    } else {
                        SecureField(
                            "",
                            text: $store.password,
                            prompt: Text("비밀번호 입력")
                                .font(.pretendardSubtitle2)
                                .foregroundColor(AppColor.grayscale500)
                        )
                    }
                }
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale900)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                Button {
                    store.send(.togglePasswordVisibility)
                } label: {
                    (store.isPasswordVisible ? Image.eyeIcon : Image.eyeOffIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            
            Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
            
            VStack(alignment: .leading, spacing: 4) {
                ValidationCheckRow(
                    text: "8자리 이상",
                    isValid: store.isPasswordLengthValid
                )
                ValidationCheckRow(
                    text: "영문 대소문자, 숫자, 특수문자 중 2가지 이상 포함",
                    isValid: store.isPasswordComplexityValid
                )
            }
        }
    }
    
    private var passwordConfirmSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("비밀번호 확인")
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale700)
            
            HStack {
                Group {
                    if store.isPasswordConfirmVisible {
                        TextField(
                            "",
                            text: Binding(
                                get: { store.passwordConfirm },
                                set: { store.send(.passwordConfirmChanged($0)) }
                            ),
                            prompt: Text("비밀번호 재입력")
                                .font(.pretendardSubtitle2)
                                .foregroundColor(AppColor.grayscale500)
                        )
                    } else {
                        SecureField(
                            "",
                            text: Binding(
                                get: { store.passwordConfirm },
                                set: { store.send(.passwordConfirmChanged($0)) }
                            ),
                            prompt: Text("비밀번호 재입력")
                                .font(.pretendardSubtitle2)
                                .foregroundColor(AppColor.grayscale500)
                        )
                    }
                }
                .font(.pretendardSubtitle2)
                .foregroundColor(store.passwordConfirmError != nil ? AppColor.error : AppColor.grayscale900)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                Button {
                    store.send(.togglePasswordConfirmVisibility)
                } label: {
                    (store.isPasswordConfirmVisible ? Image.eyeIcon : Image.eyeOffIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            
            Rectangle()
                .fill(store.passwordConfirmError != nil ? AppColor.error : AppColor.grayscale300)
                .frame(height: 1)
            
            if let error = store.passwordConfirmError {
                Text(error)
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.error)
            }
        }
    }
}

private struct TermsAgreementBottomSheet: View {
    let isAllAgreed: Bool
    let isServiceTermsAgreed: Bool
    let isPrivacyTermsAgreed: Bool
    let onToggleAll: () -> Void
    let onToggleService: () -> Void
    let onTogglePrivacy: () -> Void
    let onConfirm: () -> Void
    @State private var selectedDetail: TermsDetailType?
    
    private var canConfirm: Bool {
        isServiceTermsAgreed && isPrivacyTermsAgreed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("서비스 이용약관에\n동의해주세요")
                .font(.pretendardHeadline2)
                .foregroundColor(AppColor.grayscale900)
                .padding(.horizontal, 20)
                .padding(.bottom, 55)
                .padding(.top, 40)

            VStack(spacing: 12) {
                agreementRow(
                    title: "약관에 모두 동의",
                    isSelected: isAllAgreed,
                    textColor: AppColor.grayscale900,
                    textFont: .pretendardCaption1,
                    showChevron: false,
                    onToggle: onToggleAll
                )

                agreementRow(
                    title: "코치코치 서비스 이용약관(필수)",
                    isSelected: isServiceTermsAgreed,
                    textColor: AppColor.grayscale700,
                    textFont: .pretendardCaption2,
                    showChevron: true,
                    onToggle: onToggleService,
                    onOpenDetail: {
                        selectedDetail = .service
                    }
                )

                agreementRow(
                    title: "개인정보 처리방침(필수)",
                    isSelected: isPrivacyTermsAgreed,
                    textColor: AppColor.grayscale700,
                    textFont: .pretendardCaption2,
                    showChevron: true,
                    onToggle: onTogglePrivacy,
                    onOpenDetail: {
                        selectedDetail = .privacy
                    }
                )
            }

            Spacer(minLength: 16)

            BottomButton(
                title: "확인",
                style: canConfirm ? .primary : .secondary,
                action: onConfirm
            )
            .disabled(!canConfirm)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(AppColor.grayscale100.ignoresSafeArea())
        .sheet(item: $selectedDetail) { detail in
            TermsDetailSheetView(detail: detail)
                .presentationDetents([.large])
                .presentationCornerRadius(24)
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color.white)
        }
    }

    private func agreementRow(
        title: String,
        isSelected: Bool,
        textColor: Color,
        textFont: Font,
        showChevron: Bool,
        onToggle: @escaping () -> Void,
        onOpenDetail: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image.checkmarkIcon
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale400)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            if let onOpenDetail {
                Button(action: onOpenDetail) {
                    Text(title)
                        .font(textFont)
                        .foregroundColor(textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            } else {
                Text(title)
                    .font(textFont)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if showChevron, let onOpenDetail {
                Button(action: onOpenDetail) {
                    Image.chevronRightOutlineIcon
                        .renderingMode(.template)
                        .foregroundColor(AppColor.grayscale400)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
}

private enum TermsDetailType: String, Identifiable {
    case service
    case privacy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .service:
            return "서비스 이용약관"
        case .privacy:
            return "개인정보 처리방침"
        }
    }

    var content: String {
        switch self {
        case .service:
            return """
            이용 약관 전문

            1. 목적 및 정의
            - 본 약관은 코치코치앱(이하 "서비스")의 이용 조건 및 절차, 권리·의무를 규정합니다.
            - 서비스는 카페 운영에 필요한 원가·수익성 분석을 돕기 위한 참고용 정보 제공 목적입니다.
            - 계산 결과는 법적·세무적·회계적 자문이 아닙니다.

            2. 회원 가입 및 계정 관리
            - 회원은 정확한 정보를 입력해야 합니다.
            - 계정 정보 관리 책임은 사용자에게 있습니다.
            - 타인의 계정 사용, 양도, 대여를 금지합니다.

            3. 서비스 내용 및 제공 범위
            - 사용자가 입력한 메뉴, 재료비, 비용 정보를 바탕으로 원가, 마진율, 공헌이익, 권장 가격 등의 분석 정보를 제공합니다.
            - 서비스 내용은 운영 정책에 따라 변경·추가·중단될 수 있습니다.

            4. 사용자 입력 정보의 책임
            - 모든 분석 결과는 사용자가 입력한 정보에 의존합니다.
            - 입력 정보의 정확성, 최신성에 대한 책임은 사용자에게 있습니다.
            - 잘못된 입력으로 인한 손실에 대해 서비스는 책임을 지지 않습니다.

            5. 서비스 이용의 제한 및 중단
            - 시스템 점검, 장애, 불가항력 사유 시 서비스가 일시 중단될 수 있습니다.
            - 회사는 사전 공지 후 또는 불가피한 경우 사후 공지로 서비스 중단이 가능합니다.

            6. 지식재산권
            - 서비스에 포함된 UI, 콘텐츠, 분석 로직, 계산 방식의 저작권은 회사에 귀속됩니다.
            - 사용자는 개인적인 서비스 이용 범위 내에서만 사용 가능합니다.

            7. 책임의 제한 및 면책
            - 서비스에서 제공되는 분석, 가이드, 권장 가격은 의사결정을 돕는 참고 자료입니다.
            - 실제 경영 판단, 손익 결과에 대한 책임은 사용자에게 있습니다.
            - 회사는 간접 손해, 영업 손실, 기대 수익 손실에 대해 책임을 지지 않습니다.
            - 서비스의 일부 기능은 자동화된 분석 또는 AI 기반 로직을 활용합니다.
            - AI 분석 결과는 참고용 정보이며, 항상 정확하거나 최신임을 보장하지 않습니다.
            - AI 결과에 대한 최종 판단 및 책임은 사용자에게 있습니다.

            8. 계약 해지 및 회원 탈퇴
            - 사용자는 언제든지 앱 내 기능을 통해 회원 탈퇴가 가능합니다.
            - 탈퇴 시 관련 법령에 따라 일부 정보는 보관될 수 있습니다.
            - 구체적 보관 내용은 개인정보 처리방침을 따릅니다.

            9. 약관의 변경
            - 약관 변경 시 앱 내 공지 또는 기타 합리적인 방법으로 고지합니다.
            - 변경 후에도 서비스를 계속 이용할 경우 동의로 간주합니다.

            10. 준거법 및 분쟁 해결
            - 본 약관은 대한민국 법을 준거법으로 합니다.
            """
        case .privacy:
            return """
            개인정보 처리방침 전문

            본 개인정보 처리방침은 코치코치앱(이하 "회사")이 제공하는 서비스와 관련하여, 이용자의 개인정보를 어떻게 수집·이용·보관·처리하는지를 설명합니다.

            1. 수집하는 개인정보 항목
            회사는 회원가입 및 서비스 제공을 위해 다음의 정보를 수집합니다.
            - 아이디
            - 비밀번호(암호화하여 저장)
            - 서비스 이용 기록

            2. 개인정보 수집 및 이용 목적
            회사는 수집한 개인정보를 다음 목적에 한하여 이용합니다.
            - 회원 식별 및 서비스 이용 관리
            - 원가·수익성 분석 등 서비스 제공
            - 서비스 오류 확인 및 개선

            3. 개인정보 보관 및 이용 기간
            회사는 개인정보를 원칙적으로 회원 탈퇴 시까지 보관합니다.
            다만, 관련 법령에 따라 보관이 필요한 경우에는 해당 법령에서 정한 기간 동안 보관할 수 있습니다.

            4. 개인정보의 제3자 제공
            회사는 이용자의 개인정보를 제3자에게 제공하지 않습니다.

            5. 개인정보 처리 위탁
            회사는 개인정보 처리를 외부 업체에 위탁하지 않습니다.

            6. 이용자의 권리
            이용자는 언제든지 서비스 내 기능을 통해 회원 탈퇴를 요청할 수 있으며, 탈퇴 시 개인정보는 관련 법령에 따라 처리됩니다.

            7. 개인정보 보호를 위한 조치
            회사는 개인정보 보호를 위해 비밀번호 암호화 등 합리적인 보안 조치를 적용하고 있습니다.

            8. 개인정보 관련 문의
            개인정보 처리와 관련한 문의는 앱 내 고객문의 채널(coach.operation@gmail.com)을 통해 접수할 수 있습니다.

            9. 개인정보 처리방침의 변경
            본 개인정보 처리방침은 관련 법령 또는 서비스 정책 변경에 따라 수정될 수 있으며, 변경 시 앱 내 공지를 통해 안내합니다.
            """
        }
    }
}

private struct TermsDetailSheetView: View {
    let detail: TermsDetailType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            NavigationTopBar(
                onBackTap: { dismiss() },
                verticalPadding: 12,
                barHeight: 56,
                backgroundColor: .white
            )

            ScrollView {
                Text(detail.content)
                    .font(.pretendardBody2)
                    .foregroundColor(AppColor.grayscale700)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

private struct ValidationCheckRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isValid ? AppColor.primaryBlue500 : AppColor.grayscale600)
            
            Text(text)
                .font(.pretendardCaption2)
                .foregroundColor(isValid ? AppColor.primaryBlue500 : AppColor.grayscale600)
        }
    }
}

#Preview {
    SignUpView(
        store: Store(initialState: SignUpFeature.State()) {
            SignUpFeature()
        }
    )
}
