//
//  DailyPortionLogViewModel.swift
//  Optimal Health
//
//  Created by Daniel Pressner on 10.11.22.
//

import Foundation
import Combine
import ScrollingCalendar

class DailyPortionLogViewModel: ObservableObject {
  
  @Published var currentLog: DailyLog?
  @Published var currentLogNutrients: [NutrientEntry] = []
  @Published var selectedDate = Date()
 
  let updateNutrientConsumedPublisher = PassthroughSubject<(NutrientEntry, Int), Never>()
  
  private let contextChangePublisher = NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextObjectsDidChange)
  
  private let calendar = Calendar.current
  
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    
    $currentLog
      .map { $0?.nutrientsArray }
      .replaceNil(with: [])
      .assign(to: &$currentLogNutrients)
    
    //Subscribe to publishers
    didUpdateSelectedDate()
    contextDidChangeRefreshLog()
    updateNutrientConsumedPublisher
      .sink { nutrient, amount in
        self.update(nutrient: nutrient, portionsConsumedBy: amount)
      }
      .store(in: &subscriptions)
  }
}

//MARK: - Combine subscribe functions
extension DailyPortionLogViewModel {
  func didUpdateSelectedDate() {
    $selectedDate
      .map { try? self.fetchLog(for: $0) }
      .assign(to: &$currentLog)
  }
  
  func contextDidChangeRefreshLog() {
    contextChangePublisher
      .map { _ in try? self.fetchLog(for: self.selectedDate)}
      .assign(to: &$currentLog)
  }
}

//MARK: - CoreData Interactions
extension DailyPortionLogViewModel {
  func createNewLog() {
    let newLog = DailyLog(context: CoreDataController.shared.context)
    newLog.date = selectedDate
    newLog.id = UUID()
    for nutrient in Nutrient.allCases {
      let nutrientEntry = NutrientEntry(context: CoreDataController.shared.context)
      nutrientEntry.nameData = nutrient.rawValue
      nutrientEntry.id = UUID()
      nutrientEntry.portionsConsumed = 0
      nutrientEntry.portionsRecommended = UserDefaults.standard.value(forKey: nutrient.userDefaultKey) as? Int32 ?? 8
      newLog.addToNutrientEntries(nutrientEntry)
    }
    try? CoreDataController.shared.context.save()
  }
  
  func fetchLog(for date: Date) throws -> DailyLog? {
    let fetchRequest = DailyLog.dailyLogFetchRequest(for: date)
    let results = try CoreDataController.shared.context.fetch(fetchRequest)
    return results.first
  }
  
  func update(nutrient: NutrientEntry, portionsConsumedBy value: Int) {
    guard Int(nutrient.portionsConsumed) + value >= 0, Int(nutrient.portionsConsumed) + value <= 12 else { return }
    let newPortionsConsumed = Int(nutrient.portionsConsumed) + value
    nutrient.portionsConsumed = Int32(newPortionsConsumed)
    try? CoreDataController.shared.context.save()
  }
}
