//
//  Chore.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import Foundation
import SwiftUI

struct Chore: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String?
    var assignedTo: UUID?
    
    var isCompleted: Bool = false        // Approved by parent
    var isMarkedDoneByChild: Bool = false // Marked done by child
    
    var imageData: Data? = nil            // Store image as Data
    var dueDate: Date?
    var basePoints: Int = 10
    var familyId: UUID


    var image: UIImage? {
            get { imageData.flatMap { UIImage(data: $0) } }
            set { imageData = newValue?.jpegData(compressionQuality: 0.8) }
        }
    }
