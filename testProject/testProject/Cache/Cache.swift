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


    func insert(_ value: Value, forKey key: Key) {
        let date = self.dateProvider().addingTimeInterval(entryLifeTime)
        let entry = Entry(key: key, value: value, expirationDate: date)


        self.wrapped.setObject(entry, forKey: WrappedKey(key))

        self.keyTracker.keys.insert(key)
    }
    
    func value(forKey key: Key) -> Value? {
        
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
        get { return self.value(forKey: key) }
        
        set {
            if let value = newValue {
                self.insert(value, forKey: key)
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
            
            self.keys.remove(entry.key)
        }
    }
    
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

private extension Cache {

    func entry(forKey key: Key) -> Entry? {
        guard let entry = self.wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard self.dateProvider() < entry.expirationDate else {
            self.removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        self.wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        self.keyTracker.keys.insert(entry.key)
    }
}

extension Cache: Codable where Key: Codable, Value: Codable {
    
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }

}

extension Cache where Key: Codable, Value: Codable {
    
    // get value from cache or file manager
    func getValue(forKey key: Key) -> Value? {
        guard let entry = self.wrapped.object(forKey: WrappedKey(key)) else {
            let value = self.value(forKey: key)
            
            // save item to local cache if there is it
            if let value = value {
                self.insert(value, forKey: key)
            }

            return value
        }

        // check expiration date
        guard self.dateProvider() < entry.expirationDate else {
            self.removeValue(forKey: key)
            self.removeFromDisk(forKey: key)
            
            return nil
        }

        return entry.value
    }

    // Insert file to cache and file manager
    func insertValue(_ value: Value, forKey key: Key) {
        let date = self.dateProvider().addingTimeInterval(entryLifeTime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        
        self.wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        self.keyTracker.keys.insert(entry.key)
        
        do {
            try self.saveToDisk(forKey: key)
        } catch {
            print("CACH: ", error)
        }
        
    }
    
    private func saveToDisk(forKey key: Key) throws {
        guard let key = key as? String else { return }
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cacheUrl.appendingPathComponent(key + ".cache")
        let data = try JSONEncoder().encode(self)
        
        do {
            try data.write(to: fileUrl, options: .atomic)
            print("CACH: Записан файл в хранилище")

        } catch {
            print("CACH: Ощибка записи в хранилище", error.localizedDescription)
        }
    }
    
    private func removeFromDisk(forKey key: Key) {
        guard let key = key as? String else { return }
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cacheUrl.appendingPathComponent(key + ".cache")
        
        do {
            try fileManager.removeItem(at: fileUrl)
            print("CACH: Файл удален из хранилища")
        } catch {
            print("CACH: - Ощибка удаления файла с хранилища ", error.localizedDescription)
        }
    }
    
    private func value(forKey key: Key) -> Value? {
        guard let key = key as? String else { return nil }
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cacheUrl.appendingPathComponent(key + ".cache")

        do {
            let data = try Data(contentsOf: fileUrl)
            let entry = try JSONDecoder().decode(Array<Entry>.self.self, from: data)
            print("CACH: -  чтение файла с хранилища успешно ", " for key \(key)", entry.forEach({ print($0.key)}))

            return entry.first?.value
        } catch {
            print("CACH: ERROR GET VALUE FROM DISK - ", " \(fileUrl): \(error.localizedDescription)")
        }
        
        return nil
    }
}

