import SwiftUI

public struct NavigationTopBar: View {
  private let leadingContent: AnyView
  private let trailingContent: AnyView
  private let horizontalPadding: CGFloat
  private let verticalPadding: CGFloat
  private let barHeight: CGFloat
  private let backgroundColor: Color
  
  public init(
    onBackTap: @escaping () -> Void,
    title: String? = nil,
    trailing: TrailingAction? = nil,
    verticalPadding: CGFloat = 12,
    barHeight: CGFloat = 50,
    backgroundColor: Color = .white
  ) {
    self.horizontalPadding = 20
    self.verticalPadding = verticalPadding
    self.barHeight = barHeight
    self.backgroundColor = backgroundColor

    self.leadingContent = AnyView(
      Button(action: onBackTap) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
          .frame(width: 24, height: 24)
      }
      .buttonStyle(.plain)
    )
    
    if let trailing = trailing {
      switch trailing {
      case let .text(text, action):
        self.trailingContent = AnyView(
          HStack {
            if let title = title {
              Spacer()
              Text(title)
                .font(.pretendardSubtitle1)
                .foregroundColor(AppColor.grayscale900)
            }
            Spacer()
            Button(action: action) {
              Text(text)
                .font(.pretendardCTA)
                .foregroundColor(AppColor.grayscale600)
            }
            .buttonStyle(.plain)
          }
        )
      case let .icon(image, action):
        self.trailingContent = AnyView(
          HStack {
            if let title = title {
              Spacer()
              Text(title)
                .font(.pretendardSubtitle1)
                .foregroundColor(AppColor.grayscale900)
            }
            Spacer()
            Button(action: action) {
              image
                .renderingMode(.template)
                .foregroundColor(AppColor.grayscale600)
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
          }
        )
      }
    } else if let title = title {
      self.trailingContent = AnyView(
        HStack {
          Spacer()
          Text(title)
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale900)
          Spacer()
        }
      )
    } else {
      self.trailingContent = AnyView(Spacer())
    }
  }
  
  public init<Leading: View, Trailing: View>(
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder trailing: () -> Trailing,
    horizontalPadding: CGFloat = 24,
    verticalPadding: CGFloat = 12,
    barHeight: CGFloat = 48,
    backgroundColor: Color = .white
  ) {
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.barHeight = barHeight
    self.backgroundColor = backgroundColor

    self.leadingContent = AnyView(leading())
    self.trailingContent = AnyView(trailing())
  }
  
  public var body: some View {
    HStack {
      leadingContent
      trailingContent
    }
    .padding(.horizontal, horizontalPadding)
    .padding(.vertical, verticalPadding)
    .frame(height: barHeight)
    .background(backgroundColor)
  }
  
  public enum TrailingAction {
    case text(String, action: () -> Void)
    case icon(Image, action: () -> Void)
  }
}

public struct SheetDragHandle: View {
  public init() {}

  public var body: some View {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
      .fill(AppColor.grayscale300)
      .frame(width: 60, height: 7)
      .frame(maxWidth: .infinity)
      .padding(.top, 20)
      .accessibilityHidden(true)
  }
}

#Preview {
  VStack(spacing: 20) {
    NavigationTopBar(onBackTap: {})
    
    NavigationTopBar(
      onBackTap: {},
      title: "재료"
    )
    
    NavigationTopBar(
      onBackTap: {},
      title: "재료",
      trailing: .icon(Image.starIcon.resizable().frame(width: 32,height: 32) as! Image, action: {})
    )
    
    NavigationTopBar(
      onBackTap: {},
      trailing: .text("관리", action: {})
    )
    
    NavigationTopBar(
      leading: {
        HStack(spacing: 4) {
          Text("재료")
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.grayscale900)
          Text("10")
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.primaryBlue500)
        }
      },
      trailing: {
        HStack(spacing: 16) {
          Button(action: {}) {
            Image.searchIcon
              .frame(width: 24, height: 24)
          }
          Button(action: {}) {
            Image.meatballIcon
              .frame(width: 24, height: 24)
          }
        }
      }
    )
    
    Spacer()
  }
}
