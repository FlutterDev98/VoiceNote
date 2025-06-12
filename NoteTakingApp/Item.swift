//
//  Item.swift
//  NoteTakingApp
//
//  Created by Nuriddin Jumayev on 12/06/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
