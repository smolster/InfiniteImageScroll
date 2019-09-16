//
//  DateFormatter+Extension.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/12/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

extension DateFormatter {
    /// Returns an ISO-8601 formatter, set to en_US locale and GMT.
    static func iso8601() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }
}
