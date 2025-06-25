import Foundation
import JavaScriptCore

class MyanmarCalendar {
    private let jsContext: JSContext
    private var myanmarDateTime: JSValue
    
    init() throws {
        // Create JavaScript context
        jsContext = JSContext()
        
        // Set up error handling
        jsContext.exceptionHandler = { context, exception in
            print("JavaScript Error: \(exception?.toString() ?? "Unknown error")")
        }
        
        // Read the JavaScript file
        guard let jsPath = Bundle.main.path(forResource: "ceMmDateTime_Swift", ofType: "js"),
              let jsContent = try? String(contentsOfFile: jsPath, encoding: .utf8) else {
            throw MyanmarCalendarError.failedToLoadJavaScript
        }
        
        // Evaluate the JavaScript code
        jsContext.evaluateScript(jsContent)
        
        // Check if classes are available
        guard let ceDateTimeClass = jsContext.objectForKeyedSubscript("ceDateTime"),
              let ceMmDateTimeClass = jsContext.objectForKeyedSubscript("ceMmDateTime"),
              !ceDateTimeClass.isUndefined,
              !ceMmDateTimeClass.isUndefined else {
            print("JavaScript classes not found after evaluation")
            throw MyanmarCalendarError.failedToCreateInstance
        }
        
        // Create an instance of ceMmDateTime using 'new' operator
        let newScript = "new ceMmDateTime()"
        guard let instance = jsContext.evaluateScript(newScript),
              !instance.isUndefined,
              !instance.isNull else {
            print("Failed to create ceMmDateTime instance")
            throw MyanmarCalendarError.failedToCreateInstance
        }
        
        myanmarDateTime = instance
    }
    
    // Initialize with custom Julian date
    init(julianDate: Double) throws {
        // Create JavaScript context
        jsContext = JSContext()
        
        // Set up error handling
        jsContext.exceptionHandler = { context, exception in
            print("JavaScript Error: \(exception?.toString() ?? "Unknown error")")
        }
        
        // Read the JavaScript file
        guard let jsPath = Bundle.main.path(forResource: "ceMmDateTime_Swift", ofType: "js"),
              let jsContent = try? String(contentsOfFile: jsPath, encoding: .utf8) else {
            throw MyanmarCalendarError.failedToLoadJavaScript
        }
        
        // Evaluate the JavaScript code
        jsContext.evaluateScript(jsContent)
        
        // Check if classes are available
        guard let ceDateTimeClass = jsContext.objectForKeyedSubscript("ceDateTime"),
              let ceMmDateTimeClass = jsContext.objectForKeyedSubscript("ceMmDateTime"),
              !ceDateTimeClass.isUndefined,
              !ceMmDateTimeClass.isUndefined else {
            print("JavaScript classes not found after evaluation")
            throw MyanmarCalendarError.failedToCreateInstance
        }
        
        // Create an instance of ceMmDateTime with Julian date using script evaluation
        let newScript = "new ceMmDateTime(\(julianDate))"
        guard let instance = jsContext.evaluateScript(newScript),
              !instance.isUndefined,
              !instance.isNull else {
            print("Failed to create ceMmDateTime instance with Julian date: \(julianDate)")
            throw MyanmarCalendarError.failedToCreateInstance
        }
        
        myanmarDateTime = instance
    }
    
    // Convert Western date to Julian date (equivalent to ceDateTime.w2j)
    static func westernToJulian(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) throws -> Double {
        let jsContext = JSContext()
        
        // Set up error handling
        jsContext?.exceptionHandler = { context, exception in
            print("JavaScript Error in westernToJulian: \(exception?.toString() ?? "Unknown error")")
        }
        
        // Read the JavaScript file
        guard let jsPath = Bundle.main.path(forResource: "ceMmDateTime_Swift", ofType: "js"),
              let jsContent = try? String(contentsOfFile: jsPath, encoding: .utf8) else {
            throw MyanmarCalendarError.failedToLoadJavaScript
        }
        
        // Evaluate the JavaScript code
        jsContext?.evaluateScript(jsContent)
        
        // Call ceDateTime.w2j function using script evaluation
        let w2jScript = "ceDateTime.w2j(\(year), \(month), \(day), \(hour), \(minute), \(second))"
        guard let w2jResult = jsContext?.evaluateScript(w2jScript),
              !w2jResult.isUndefined,
              !w2jResult.isNull else {
            print("Failed to call ceDateTime.w2j with parameters: \(year), \(month), \(day), \(hour), \(minute), \(second)")
            throw MyanmarCalendarError.failedToCreateInstance
        }
        
        return w2jResult.toDouble()
    }
    
    // Convenience initializer for Western date
    convenience init(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) throws {
        let julianDate = try MyanmarCalendar.westernToJulian(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        try self.init(julianDate: julianDate)
    }
    
    // Get current Myanmar date as string
    func getCurrentMyanmarDateString() -> String? {
        guard let result = myanmarDateTime.invokeMethod("ToMString", withArguments: []),
              !result.isUndefined,
              !result.isNull else {
            return nil
        }
        let stringValue = result.toString()
        return stringValue == "undefined" ? nil : stringValue
    }
    
    // Helper function to safely get string values
    private func safeStringValue(for key: String) -> String? {
        guard let value = myanmarDateTime.objectForKeyedSubscript(key),
              !value.isUndefined,
              !value.isNull else {
            return nil
        }
        let stringValue = value.toString()
        return (stringValue == "undefined" || stringValue?.isEmpty == true) ? nil : stringValue
    }
    
    // Helper function to safely get integer values
    private func safeIntValue(for key: String) -> Int? {
        guard let value = myanmarDateTime.objectForKeyedSubscript(key),
              !value.isUndefined,
              !value.isNull else {
            return nil
        }
        return Int(value.toInt32())
    }
    
    // Helper function to safely get double values
    private func safeDoubleValue(for key: String) -> Double? {
        guard let value = myanmarDateTime.objectForKeyedSubscript(key),
              !value.isUndefined,
              !value.isNull else {
            return nil
        }
        return value.toDouble()
    }
    
    // Get various properties using safe accessors
    var pyathada: String? {
        return safeStringValue(for: "pyathada")
    }
    
    var julianDate: Double? {
        return safeDoubleValue(for: "jd")
    }
    
    var myanmarYear: Int? {
        return safeIntValue(for: "my")
    }
    
    var myanmarMonth: Int? {
        return safeIntValue(for: "mm")
    }
    
    var myanmarDay: Int? {
        return safeIntValue(for: "md")
    }
    
    var sabbath: String? {
        return safeStringValue(for: "sabbath")
    }
    
    var yatyaza: String? {
        return safeStringValue(for: "yatyaza")
    }
    
    var nagahle: String? {
        return safeStringValue(for: "nagahle")
    }
    
    var mahabote: String? {
        return safeStringValue(for: "mahabote")
    }
    
    var nakhat: String? {
        return safeStringValue(for: "nakhat")
    }
    
    var weekday: Int? {
        return safeIntValue(for: "w")
    }
    
    var year: Int? {
        return safeIntValue(for: "y")
    }
    
    var month: Int? {
        return safeIntValue(for: "m")
    }
    
    var day: Int? {
        return safeIntValue(for: "d")
    }
}

enum MyanmarCalendarError: Error {
    case failedToLoadJavaScript
    case failedToCreateInstance
}
