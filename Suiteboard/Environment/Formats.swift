//
//  Formats.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import Prelude

private let defaultThresholdInDays = 30  // days

private struct DateFormatterConfig {
    fileprivate let template: String?
    fileprivate let dateStyle: DateFormatter.Style?
    fileprivate let locale: Locale
    fileprivate let timeStyle: DateFormatter.Style?
    fileprivate let timeZone: TimeZone
    
    fileprivate func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = self.locale
        formatter.timeZone = self.timeZone
        if let template = self.template {
            formatter.dateFormat = template
            formatter.date(from: "2018-03-23")
            
        }
        if let dateStyle = self.dateStyle {
            formatter.dateStyle = dateStyle
        }
        if let timeStyle = self.timeStyle {
            formatter.timeStyle = timeStyle
        }
        
        return formatter
    }
    
    fileprivate static var formatters: [DateFormatterConfig: DateFormatter] = [:]
    
    fileprivate static func cachedFormatter(forConfig config: DateFormatterConfig) -> DateFormatter {
        let formatter = self.formatters[config] ?? config.formatter()
        self.formatters[config] = formatter
        return formatter
    }
}

extension DateFormatterConfig: Hashable {
    fileprivate func hash(into hasher: inout Hasher) {
        hasher.combine(self.template?.hashValue ?? 0)
//        (self.template?.hashValue ?? 0) ^ (self.dateStyle?.hashValue ?? 0) ^ self.locale.hashValue ^ (self.timeStyle?.hashValue ?? 0) ^ self.timeZone.hashValue
    }
    
    /*
    fileprivate var hashValue: Int {
        return (self.template?.hashValue ?? 0) ^ (self.dateStyle?.hashValue ?? 0) ^ self.locale.hashValue ^ (self.timeStyle?.hashValue ?? 0) ^ self.timeZone.hashValue
    }
    */
}

private func == (lhs: DateFormatterConfig, rhs: DateFormatterConfig) -> Bool {
    return lhs.template == rhs.template && lhs.dateStyle == rhs.dateStyle && lhs.locale == rhs.locale && lhs.timeStyle == rhs.timeStyle && lhs.timeZone == rhs.timeZone
}

public enum Format {
    
    public static func date(secondsInUTC seconds: TimeInterval, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium, timeZone: TimeZone? = nil, env: Environment = AppEnvironment.current) -> String {
        let formatter = DateFormatterConfig.cachedFormatter(forConfig: .init(template: nil, dateStyle: dateStyle, locale: env.locale, timeStyle: timeStyle, timeZone: timeZone ?? env.calendar.timeZone))
        
        return formatter.string(from: env.dateType.init(timeIntervalSince1970: seconds).date)
    }
    
    public static func date(secondsInUTC seconds: TimeInterval, template: String, timeZone: TimeZone? = nil) -> String? {
        let formatter = DateFormatterConfig.cachedFormatter(forConfig: .init(template: template, dateStyle: nil, locale: AppEnvironment.current.locale, timeStyle: nil, timeZone: timeZone ?? AppEnvironment.current.calendar.timeZone))
        
        return formatter.string(from: AppEnvironment.current.dateType.init(timeIntervalSince1970: seconds).date)
    }
    
    public static func stringToDate(rawDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: rawDate) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        return date
    }
    
    public static func dateFormatterString(date: Date, template: String) -> String {
        let printFormatter = DateFormatter()
        printFormatter.dateFormat = template
        
        let summaryDate = printFormatter.string(from: date)
        
        return summaryDate
    }
}
