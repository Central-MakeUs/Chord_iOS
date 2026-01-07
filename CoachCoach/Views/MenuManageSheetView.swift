import SwiftUI

struct MenuManageSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var tagText: String = ""
  @State private var tags: [String] = ["음료", "디저트"]
  @State private var hasChanges = false

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(AppColor.grayscale300)
        .frame(width: 60, height: 6)
        .padding(.top, 12)

      VStack(alignment: .leading, spacing: 24) {
        Text("메뉴 관리")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)

        VStack(alignment: .leading, spacing: 12) {
          TagInputField(
            text: $tagText,
            placeholder: "메뉴 태그 직접 작성하기",
            height: 47,
            backgroundColor: .clear,
            onTapAdd: addTag
          )

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(tags, id: \.self) { option in
                MenuTagChip(title: option) {
                  removeTag(option)
                }
              }
            }
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)

      Spacer(minLength: 20)

      let isEnabled = hasChanges || !tagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      BottomButton(
        title: "완료",
        style: isEnabled ? .primary : .secondary
      ) {
        guard isEnabled else { return }
        addTag()
        dismiss()
      }
      .disabled(!isEnabled)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(AppColor.grayscale100)
  }

  private func addTag() {
    let trimmed = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    if !tags.contains(trimmed) {
      tags.append(trimmed)
      hasChanges = true
    }
    tagText = ""
  }

  private func removeTag(_ tag: String) {
    tags.removeAll { $0 == tag }
    hasChanges = true
  }
}

private struct MenuTagChip: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 4) {
        Text(title)
          .font(.pretendardCTA)
          .foregroundColor(AppColor.grayscale600)

        Image.cancelRoundedIcon
          .resizable()
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale600)
          .scaledToFit()
          .frame(width: 16, height: 16)
      }
      .padding(.leading, 16)
      .padding(.trailing, 8)
      .padding(.vertical, 6)
      .frame(height: 36)
      .background(
        Capsule()
          .fill(AppColor.grayscale100)
      )
      .overlay(
        Capsule()
          .strokeBorder(AppColor.grayscale600, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  MenuManageSheetView()
    .environment(\.colorScheme, .light)
}
