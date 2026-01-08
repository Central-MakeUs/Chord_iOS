import SwiftUI

struct MenuRegistrationView: View {
  enum Category: String, CaseIterable, Hashable {
    case beverage = "음료"
    case dessert = "디저트"
  }

  @State private var menuName = ""
  @State private var price = ""
  @State private var selectedCategory: Category = .beverage
  @State private var ingredients: [String] = ["원두"]

  let onBack: () -> Void
  let onComplete: () -> Void

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()

      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            topBar

            UnderlinedTextField(
              text: $menuName,
              title: "메뉴명",
              placeholder: "메뉴의 이름을 입력해주세요",
              titleColor: AppColor.primaryBlue500,
              trailingIcon: Image.searchIcon
            )

            UnderlinedTextField(
              text: $price,
              title: "가격",
              placeholder: "가격을 입력해주세요",
              keyboardType: .numberPad
            )

            categorySection

            VStack(alignment: .leading, spacing: 8) {
              Text("제조시간")
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale900)
            }

            ingredientSection
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
        }

        BottomButton(title: "완료", style: .primary) {
          onComplete()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
    }
  }

  private var topBar: some View {
    ZStack {
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

      Text("메뉴등록")
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale900)
    }
  }

  private var categorySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("카테고리")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        ForEach(Category.allCases, id: \.self) { category in
          Button(action: { selectedCategory = category }) {
            Text(category.rawValue)
              .font(.pretendardCaption1)
              .foregroundColor(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale600)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(
                RoundedRectangle(cornerRadius: 14)
                  .fill(selectedCategory == category ? AppColor.primaryBlue100 : AppColor.grayscale100)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale300, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private var ingredientSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("재료")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        Spacer()
        Button(action: {}) {
          HStack(spacing: 4) {
            Text("추가")
              .font(.pretendardCaption1)
            Text("+")
              .font(.pretendardCaption1)
          }
          .foregroundColor(AppColor.grayscale100)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(AppColor.primaryBlue500)
          )
        }
        .buttonStyle(.plain)
      }

      VStack(alignment: .leading, spacing: 8) {
        ForEach(ingredients, id: \.self) { item in
          Text(item)
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
      }
    }
    .padding(16)
    .background(AppColor.grayscale200)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  MenuRegistrationView(onBack: {}, onComplete: {})
    .environment(\.colorScheme, .light)
}
