//
//  ScorerCacheData.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/5/26.
//

import SwiftUI

struct ScorerCacheData: Codable {
    let descriptions: [String: [String]]
    let vectors: [String: [[Float]]]
}
