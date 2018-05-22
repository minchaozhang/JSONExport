//
//  ModelTransformProtocol.swift
//  FYGOMS
//
//  Created by zhmch on 2018/3/19.
//  Copyright © 2018年 feeyo. All rights reserved.
//

import Foundation

protocol ModelInitializProtocol {
    init(fromDictionary dictionary: [String: Any])
}

protocol ModelTransformProtocol: ModelInitializProtocol {
    associatedtype ObjectType = Self
    
    static func model(fromResult result: Any) -> ObjectType?
    static func modelArray(fromResult result: Any) -> [ObjectType]
}

extension ModelTransformProtocol {
    static func model(fromResult result: Any) -> Self? {
        return modelArray(fromResult: result).first
    }
    
    static func modelArray(fromResult result: Any) -> [Self] {
        var models = [Self]()
        if let dic = result as? [String: Any] {
            models.append(Self.init(fromDictionary: dic))
        } else if let array = result as? [[String: Any]] {
            models += array.map({ Self.init(fromDictionary: $0) })
        }
        return models
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func int(forKey key: Key) -> Int {
        return (self[key] as? Int) ?? 0
    }
    
    func double(forKey key: Key) -> Double {
        return (self[key] as? Double) ?? 0
    }
    
    func bool(forKey key: Key) -> Bool {
        guard let value = self[key] else {
            return false
        }
        let booleans = ["false", "yes", "0"]
        if value is String {
            if booleans.contains(value as! String) {
                return false
            }
        } else if value is Int {
            return (value as! Int) != 0
        }
        return false
    }
    
    func string(forKey key: Key) -> String {
        return (self[key] as? String) ?? ""
    }
    
    func date(forKey key: Key) -> Date? {
        guard let value = self[key] else {
            return nil
        }
        if value is String {
            let time = Double(value as! String) ?? 0
            return Date(timeIntervalSince1970: time)
        } else if value is Int {
            return Date(timeIntervalSince1970: Double(value as! Int))
        } else if value is Double {
            return Date(timeIntervalSince1970: value as! Double)
        }
        return nil
    }
    
    func dateFormat(forKey key: Key, dateFormat: String) -> String {
        if let date = date(forKey: key) {
            return date.dateString(withFormat: dateFormat)
        }
        return "--:--"
    }
    
    func model<T: ModelInitializProtocol>(forKey key: Key) -> T? {
        if let dic = self[key] as? [String: Any] {
            return T(fromDictionary: dic)
        }
        return nil
    }
    
    func modelArray<T: ModelInitializProtocol>(forKey key: Key) -> [T] {
        var list = [T]()
        if let listArray = self[key] as? [[String: Any]] {
            for dic in listArray {
                list.append(T(fromDictionary: dic))
            }
        }
        return list
    }
}
