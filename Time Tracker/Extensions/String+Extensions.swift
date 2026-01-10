//
//  String+Extensions.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/8/26.
//

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}
