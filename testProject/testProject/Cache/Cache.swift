//
//  Cache.swift
//  testProject
//
//  Created by Galina Fedorova on 13.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

final class Cache<Key: Hashable, Value> {

    private let wrapped = NSCache<WrappedKey, Entry>()
    private let fileManager: FileManager = .default
    
    private let dateProvider: () -> Date
    private let entryLifeTime: TimeInterval
    private let keyTracker = KeyTracker()
    
    
    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 12 * 60 * 60,
         maximumEntryCount: Int = 50) {

        self.dateProvider = dateProvider
        self.entryLifeTime = entryLifetime

        self.wrapped.countLimit = maximumEntryCount
        self.wrapped.delegate = self.keyTracker
    }

    func insertToTampCache(_ value: Value, forKey key: Key) {
        let date = self.dateProvider().addingTimeInterval(entryLifeTime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        
        self.wrapped.setObject(entry, forKey: WrappedKey(key))
        self.keyTracker.keys.insert(key)
    }
    
    func valueFromTempCache(forKey key: Key) -> Value? {
        guard let entry = self.wrapped.object(forKey: WrappedKey(key)) else { return nil }
        
        if self.dateProvider() < entry.expirationDate {
            return entry.value
        } else {
            self.removeValue(forKey: key)
            return nil
        }
    }
    
    func removeValue(forKey key: Key) {
        self.wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    subscript(key: Key) -> Value? {
        get { return self.valueFromTempCache(forKey: key) }
        
        set {
            if let value = newValue {
                self.insertToTampCache(value, forKey: key)
            } else {
                self.removeValue(forKey: key)
            }
        }
    }

}

private extension Cache {
    
    final class WrappedKey: NSObject {
        
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        override var hash: Int {
            return self.key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            if let value = object as? WrappedKey {
                return value.key == self.key
            } else {
                return false
            }
        }
    }
    
}

private extension Cache {

    final class Entry {
        
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

private extension Cache {
    
    final class KeyTracker: NSObject, NSCacheDelegate {

        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            
            guard let entry = object as? Entry else {
                return
            }
            print(entry.key)
            self.keys.remove(entry.key)
        }
    }
    
}

extension Cache where Key: Codable, Value: Codable {
    
    func getValue(forKey key: Key) -> Value? {
        guard let entry = self.wrapped.object(forKey: WrappedKey(key)) else {
            let value = self.valueFromDisk(forKey: key)
            
            if let value = value {
                print(Success.readFromDisk.description)
                self.insertToTampCache(value, forKey: key)
            }
            
            return value
        }
        
        // check expiration date
        guard self.dateProvider() < entry.expirationDate else {
            self.removeValue(forKey: key)
            self.removeFromDisk(forKey: key)
            
            return nil
        }
        
//        print(Success.readFromCache.description)
        return entry.value
    }
    
    func insertValue(_ value: Value, forKey key: Key) {
        let date = self.dateProvider().addingTimeInterval(entryLifeTime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        
        self.wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        self.keyTracker.keys.insert(entry.key)
        self.saveToDisk(forKey: key, value: value)
    }
    
    private func saveToDisk(forKey key: Key, value: Value) {
        guard let key = key as? String else {
            print("\(Error.save.description): \(Error.invalidName.description)")
            return
        }

        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cacheUrl.appendingPathComponent(key + ".cache")
        
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: fileUrl, options: .atomic)
            print(Success.saveToDisk.description, key)
        } catch {
            print(Error.save.rawValue, error.localizedDescription)
        }
    }
    
    private func removeFromDisk(forKey key: Key) {
        guard let key = key as? String else {
            print("\(Error.delete.description): \(Error.invalidName.description)")
            return
        }
        
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cacheUrl.appendingPathComponent(key + ".cache")
        
        do {
            try fileManager.removeItem(at: fileUrl)
        } catch {
            print(Error.delete.description, error.localizedDescription)
        }
    }
    
    private func valueFromDisk(forKey key: Key) -> Value? {
        guard let key = key as? String else {
            print("\(Error.read.description): \(Error.invalidName.description)")
            return nil
        }
        
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cacheUrl.appendingPathComponent(key + ".cache")

        do {
            let data = try Data(contentsOf: fileUrl)
            let value = try JSONDecoder().decode(Value.self, from: data)
            
            return value
        } catch {
            print(Error.read.description, error.localizedDescription)
        }
        
        return nil
    }
}

