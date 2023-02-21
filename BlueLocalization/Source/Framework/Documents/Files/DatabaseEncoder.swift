//
//  DatabaseEncoder.swift
//  BlueLocalization
//
//  Created by Florian Pircher on 17.02.23.
//  Copyright © 2023 Localization Suite. All rights reserved.
//

import Foundation

@objc(DatabaseEncoder)
public class DatabaseEncoder: NSObject {
	struct Context {
		var isInline: Bool
	}
	
	@objc public static func encode(_ database: [String: AnyObject]) -> Data {
		let context = Context(isInline: false)
		let contents = encode(dictionary: database, context: context) + "\n"
		return contents.data(using: .utf8)!
	}
	
	static func encode(dictionary: [String: AnyObject], context: Context) -> String {
		var entries: [(key: String, value: String)] = []
		
		for key in dictionary.keys.sorted() {
			let encodedKey = encode(string: key, context: context)
			let encodedValue = encode(value: dictionary[key]!, context: context)
			entries.append((encodedKey, encodedValue))
		}
		
		if context.isInline {
			return "{ \(entries.map { "\($0) = \($1)" }.joined(separator: "; ")) }"
		}
		else {
			return "{\n\(entries.map { "\($0) = \($1);\n" }.joined())}"
		}
	}
	
	static func encode(array: [AnyObject], context: Context) -> String {
		let entries = array.map { encode(value: $0, context: context) }
		
		if context.isInline {
			return "(\(entries.joined(separator: ", ")))"
		}
		else {
			return "(\n\(entries.map { "\($0),\n" }.joined()))"
		}
	}
	
	static let unquotedStringCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
	static let unquotedStringIllegalHeadCharacterSet = CharacterSet(charactersIn: "0123456789-.")
	
	static func encode(string: String, context: Context) -> String {
		let isUnquoted = (string.unicodeScalars.first.map { !unquotedStringIllegalHeadCharacterSet.contains($0) } ?? false)
			&& string.unicodeScalars.allSatisfy { unquotedStringCharacterSet.contains($0) }
		
		if isUnquoted {
			return string
		}
		else {
			return "\"" + string.replacingOccurrences(of: #"\"#, with: #"\\"#).replacingOccurrences(of: "\"", with: #"\""#) + "\""
		}
	}
	
	static func encode(int: Int, context: Context) -> String {
		int.description
	}
	
	static func encode(double: Double, context: Context) -> String {
		double.description
	}
	
	static let dateFormatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()
	
	static func encode(date: Date, context: Context) -> String {
		encode(string: dateFormatter.string(from: date), context: context)
	}
	
	static func encode(value: AnyObject, context: Context) -> String {
		if let string = value as? String {
			return encode(string: string, context: context)
		}
		else if let int = value as? Int {
			return encode(int: int, context: context)
		}
		else if let double = value as? Double {
			return encode(double: double, context: context)
		}
		else if let date = value as? Date {
			return encode(date: date, context: context)
		}
		else if let array = value as? [AnyObject] {
			return encode(array: array, context: context)
		}
		else if let dictionary = value as? [String: AnyObject] {
			return encode(dictionary: dictionary, context: context)
		}
		else {
			fatalError("canncot encode value: \(value)")
		}
	}
}
