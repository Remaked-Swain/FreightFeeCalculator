//
//  CalendarDataSourceStorage.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/24/25.
//

import Foundation
import CoreData

enum CalendarDataSourceStorageError: Error {
    case saveFailed
    case fetchFailed
    case deleteFailed
}

final actor CalendarDataSourceStorage {
    private let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init(modelName: String = "CalendarModel") {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            guard let error else { return }
            fatalError("Failed to load CoreData stack: \(error)")
        }
        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer = container
    }
    
    private func saveContext() throws {
        guard backgroundContext.hasChanges else { return }
        do {
            try backgroundContext.save()
        } catch {
            throw CalendarDataSourceStorageError.saveFailed
        }
    }
}

// MARK: - CalendarDataSourceStorageProtocol Conformation
extension CalendarDataSourceStorage: CalendarDataSourceStorageProtocol {
    func readMonth(with id: UUID) async throws -> Month {
        let fetchRequest = MonthEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        fetchRequest.fetchLimit = 1
        
        let (monthEntity, dayEntities) = try await backgroundContext.perform {
            guard let monthEntity = try self.backgroundContext.fetch(fetchRequest).first,
                  let dayEntities = monthEntity.days as? Set<DayEntity>
            else { throw CalendarDataSourceStorageError.fetchFailed }
            return (monthEntity, dayEntities)
        }
        
        var daysDict = [String: Day]()
        for dayEntity in dayEntities {
            guard let id = dayEntity.id, let date = dayEntity.date else { continue }
            let day = Day(id, date, Int(dayEntity.day), isValid: dayEntity.isValid, workHours: WorkHours(rawValue: Int(dayEntity.workHoursValue)))
            daysDict[await date.dayKey()] = day
        }
        
        return Month(monthEntity.id ?? UUID(), daysDict, monthEntity.startDate ?? Date())
    }
    
    func saveMonth(_ month: Month) async throws {
        try await backgroundContext.perform {
            let fetchRequest = MonthEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", month.id as NSUUID)
            fetchRequest.fetchLimit = 1
            
            do {
                let monthEntity = try self.backgroundContext.fetch(fetchRequest).first
                let monthEntit
            } catch {
                
            }
        }
    }
    
    func deleteMonth(with id: UUID) async throws {
        
    }
    
    func readDay(with id: String) async throws -> Day {
        
    }
    
    func saveDay(_ day: Day) async throws {
        
    }
}
