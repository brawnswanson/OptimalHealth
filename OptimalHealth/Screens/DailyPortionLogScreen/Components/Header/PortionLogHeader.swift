//
//  PortionLogHeader.swift
//  Optimal Health
//
//  Created by Daniel Pressner on 10.11.22.
//

import SwiftUI

struct PortionLogHeader: View {
  
  @Binding var currentDateComponents: DateComponents
  @State var isSettingsSheetDisplayed = false
  
  var fowardDayDisabled: Bool {
    let today = Date()
    let todayComponents = returnDateComponents(today)
    return currentDateComponents == todayComponents ? true : false
  }
  
  var forwardMonthDisabled: Bool {
    guard let currentViewedDate = cal.date(from: currentDateComponents), let oneMonthFromCurrent = cal.date(byAdding: .month, value: 1, to: currentViewedDate) else { return false }
    if cal.isDate(oneMonthFromCurrent, inSameDayAs: Date()) { return false }
    else if oneMonthFromCurrent > Date() { return true }
    else { return false }
  }
  
  let cal = Calendar.current
  
  var body: some View {
    HStack {
      HStack {
        SFSymbolButton(image: Constants.Images.doubleChevronLeft, action: { changeDate(component: .month, by: -1) })
        SFSymbolButton(image: Constants.Images.chevronLeft, action: { changeDate(component: .day, by: -1) })
        Text("\(currentDateString)")
          .font(.system(size: 18))
        SFSymbolButton(image: Constants.Images.chevronRight, action: { changeDate(component: .day, by: 1) })
          .disabled(fowardDayDisabled)
        SFSymbolButton(image: Constants.Images.doubleChevronright, action: { changeDate(component: .month, by: 1) })
          .disabled(forwardMonthDisabled)
      }
      .padding(.horizontal)
      Spacer()
      Button {
        currentDateComponents = returnDateComponents(Date())
      } label: {
        Text("Today")
          .font(.system(size: 18))
      }
      Spacer()
      Button {
        isSettingsSheetDisplayed.toggle()
      } label: {
        Image(systemName: "gearshape")
          .font(.system(size: 18))
      }
      .padding((.trailing))
      .sheet(isPresented: $isSettingsSheetDisplayed) {
        SettingsSheet()
      }
    }
  }
}

extension PortionLogHeader {
  
  func changeDate(component: Calendar.Component, by value: Int) {
    guard let currentDate = cal.date(from: currentDateComponents), let newDate = cal.date(byAdding: component, value: value, to: currentDate) else { return }
    currentDateComponents = returnDateComponents(newDate)
  }
  
  func returnDateComponents(_ date: Date) -> DateComponents {
    cal.dateComponents([.year, .month, .day], from: date)
  }
  
  var currentDateString: String {
    guard let date = Calendar.current.date(from: currentDateComponents) else { return Date().formatted(date: .abbreviated, time: .omitted) }
    return date.formatted(date: .abbreviated, time: .omitted)
  }
}

struct PortionLogHeader_Preview: PreviewProvider {
  static var previews: some View {
    PortionLogHeader(currentDateComponents: .constant(Calendar.current.dateComponents([.year, .month, .day], from: Date())))
  }
}
