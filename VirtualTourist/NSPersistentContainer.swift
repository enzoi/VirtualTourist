//
//  NSPersistentContainer.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/11/17.
//  Copyright © 2017 YTK. All rights reserved.
//
//  NSPersistentContainer code below created based on the solution from Big Nerd Ranch's iOS Programming(6th ed).
//

import Foundation
import CoreData

extension NSPersistentContainer {
    func saveContextIfNeeded() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror)")
            }
        }
    }
}
