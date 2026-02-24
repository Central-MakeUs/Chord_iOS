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
        Color.clear.frame(height: 40)
        
        Text("제조 시간")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.grayscale900)
          .padding(.top, 28)
        
        ZStack {
          
          Rectangle()
            .fill(AppColor.primaryBlue100)
            .frame(height: 30)
            .cornerRadius(8)
          
          HStack(spacing: 0) {
            Spacer()
            CustomWheelPicker(
              selection: viewStore.binding(
                get: \.draftMinutes,
                send: PrepareTimeSheetFeature.Action.minutesChanged
              ),
              range: 0..<60
            )
            .frame(width: 50, height: 200)
            
            Spacer()
              .frame(width: 62)
            
            CustomWheelPicker(
              selection: viewStore.binding(
                get: \.draftSeconds,
                send: PrepareTimeSheetFeature.Action.secondsChanged
              ),
              range: 0..<60
            )
            .frame(width: 50, height: 160)
            Spacer()
          }
          

          
          HStack(spacing: 0) {
            Spacer()
            Text("분")
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale900)
              .frame(width: 50, alignment: .trailing)
              .offset(x: 4)
            
            Spacer()
              .frame(width: 62)
            
            Text("초")
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale900)
              .frame(width: 50, alignment: .trailing)
              .offset(x: 4)
            Spacer()
          }
        }
        .frame(height: 150)
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
        .padding(.bottom, 34)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
    .presentationCornerRadius(24)
  }
}

// MARK: - Custom Wheel Picker (UIKit-based)
struct CustomWheelPicker: UIViewRepresentable {
  @Binding var selection: Int
  let range: Range<Int>
  
  func makeUIView(context: Context) -> UIView {
    let containerView = UIView()
    
    let picker = UIPickerView()
    picker.delegate = context.coordinator
    picker.dataSource = context.coordinator
    
    if range.contains(selection) {
      picker.selectRow(selection - range.lowerBound, inComponent: 0, animated: false)
    }
    
    containerView.addSubview(picker)
    picker.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      picker.topAnchor.constraint(equalTo: containerView.topAnchor),
      picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      picker.heightAnchor.constraint(equalToConstant: 200)
    ])
    
    // 레이아웃이 잡힌 후 리로드해야 뷰 갱신이 확실함
    DispatchQueue.main.async {
      picker.reloadAllComponents()
    }
    
    return containerView
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    guard let picker = uiView.subviews.first(where: { $0 is UIPickerView }) as? UIPickerView else { return }
    
    if range.contains(selection) {
      let row = selection - range.lowerBound
      if picker.selectedRow(inComponent: 0) != row {
        picker.selectRow(row, inComponent: 0, animated: true)
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let parent: CustomWheelPicker
    
    init(_ parent: CustomWheelPicker) {
      self.parent = parent
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return parent.range.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
      if pickerView.subviews.count > 1 {
        pickerView.subviews[1].backgroundColor = .clear
      }
      
      let value = parent.range.lowerBound + row
      let isSelected = pickerView.selectedRow(inComponent: component) == row
      
      let label = UILabel()
      label.text = "\(value)"
      label.textAlignment = .center
      label.font = UIFont(name: "Pretendard-Medium", size: 20)!
      label.textColor = isSelected
      ? UIColor.black
        : UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0)
      label.backgroundColor = .clear
      
      return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
      return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      let value = parent.range.lowerBound + row
      parent.selection = value
      
      pickerView.reloadAllComponents()
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
