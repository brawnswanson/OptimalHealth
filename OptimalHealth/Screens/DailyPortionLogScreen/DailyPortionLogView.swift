//
//  DailyPortionLogView.swift
//  Optimal Health
//
//  Created by Daniel Pressner on 27.10.22.
//
import Foundation
import SwiftUI

struct DailyPortionLogView: View {
  
  @StateObject private var vm = DailyPortionLogViewModel()
  @State var isSettingsSheetDisplayed = false
  @Environment(\.scenePhase) var scenePhase
  
  @AppStorage(Constants.UserDefaultKeys.lastViewedDate) var lastViewedDateInterval = Date().timeIntervalSince1970
  @AppStorage(Constants.UserDefaultKeys.defaultStartUp) var startUpPreference = StartUpScreenSelection.today.rawValue
  
  var body: some View {
    VStack {
      PortionLogHeader(isSettingsSheetDisplayed: $isSettingsSheetDisplayed, currentDate: $vm.selectedDate)
        .sheet(isPresented: $isSettingsSheetDisplayed) {
          SettingsSheet()
        }
      Divider()
      Spacer()
      if vm.currentLog != nil {
        NutrientsView(nutrients: $vm.currentLogNutrients)
      } else {
        CreateLogButton(action: vm.createNewLog)
      }
      Spacer()
    }
    .onChange(of: scenePhase) { phase in
      if phase == .active {
        setToDefaultStartup()
      }
    }
    .onChange(of: vm.selectedDate) { date in
      lastViewedDateInterval = date.timeIntervalSince1970
    }
    .onAppear {
      setToDefaultStartup()
    }
  }
}

extension DailyPortionLogView {
  
  func setToDefaultStartup() {
    guard let startUpPreference = StartUpScreenSelection(rawValue: startUpPreference) else { return }
    switch startUpPreference {
    case .today:
      vm.selectedDate = Date()
    case .lastViewed:
      vm.selectedDate = Date(timeIntervalSince1970: lastViewedDateInterval)
    }
  }
}

struct DailyPortionLogView_Previews: PreviewProvider {
  static var previews: some View {
    DailyPortionLogView()
  }
}
