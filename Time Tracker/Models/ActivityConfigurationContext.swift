//
//  ActivityConfigurationContext.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/4/26.
//

import SwiftUI

struct ActivityConfigurationContext: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
}
