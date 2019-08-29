//
//  RemoteDataDescriptorCache.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/9/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKit

protocol RemoteDataDescriptable {

    var descriptor: RemoteDataDescriptor? { get }

}

extension Array where Element: RemoteDataDescriptable {

    var unique: Array {
        var set = Set<RemoteDataDescriptor>()
        return filter { element in
            if let descriptor = element.descriptor {
                return set.insert(descriptor).inserted
            }
            return true
        }
    }

}

struct RemoteDataDescriptor: Hashable, RawRepresentable {

    public typealias RawValue = [String: Any]

    public enum Kind: Int, CaseIterable {
        case create
        case delete
    }

    public let id: String

    public let version: Int

    public let kind: Kind

    public init(id: String, version: Int, kind: Kind) {
        self.id = id
        self.version = version
        self.kind = kind
    }

    public init?(rawValue: RawValue) {
        guard let id = rawValue["id"] as? String,
            let version = rawValue["version"] as? Int,
            let kindRawValue = rawValue["kind"] as? Int,
            let kind = Kind(rawValue: kindRawValue) else {
                return nil
        }

        self.id = id
        self.version = version
        self.kind = kind
    }

    public var rawValue: RawValue {
        return [
            "id": id,
            "version": version,
            "kind": kind.rawValue,
        ]
    }

    public func includes(_ descriptor: RemoteDataDescriptor) -> Bool {
        return id == descriptor.id && (version > descriptor.version || (version == descriptor.version && kind.rawValue >= descriptor.kind.rawValue))
    }

    public func supercedes(_ descriptor: RemoteDataDescriptor) -> Bool {
        return id == descriptor.id && (version > descriptor.version || (version == descriptor.version && kind.rawValue > descriptor.kind.rawValue))
    }

    public static func includes(lhs: RemoteDataDescriptor, rhs: RemoteDataDescriptor) -> Bool {
        return lhs.includes(rhs)
    }

    public static func supercedes(lhs: RemoteDataDescriptor, rhs: RemoteDataDescriptor) -> Bool {
        return lhs.supercedes(rhs)
    }

}

final class RemoteDataDescriptorCache: RawRepresentable {

    public typealias RawValue = [String: Any]

    private var descriptors = Set<RemoteDataDescriptor>()

    public init() {}

    public init?(rawValue: RawValue) {
        if let descriptorsRawValue = rawValue["descriptors"] as? [RemoteDataDescriptor.RawValue] {
            let descriptors = descriptorsRawValue.compactMap { RemoteDataDescriptor(rawValue: $0) }
            descriptors.forEach { self.descriptors.insert($0) }
        }
    }

    public var rawValue: RawValue {
        var rawValue: RawValue = [:]
        if !descriptors.isEmpty {
            rawValue["descriptors"] = descriptors.map { $0.rawValue }
        }
        return rawValue
    }

    /// Insert element descriptors not superceded by one in the set and remove all descriptors that are included by the element descriptors
    public func insert<T>(_ elements: [T]) where T: RemoteDataDescriptable {
        elements.forEach { element in
            if let elementDescriptor = element.descriptor {
                var insert = true
                self.descriptors = self.descriptors.filter {
                    if $0.supercedes(elementDescriptor) {
                        insert = false
                    }
                    if elementDescriptor.includes($0) {
                        return false
                    }
                    return true
                }
                if insert {
                    self.descriptors.insert(elementDescriptor)
                }
            }
        }
    }

    /// Remove all descriptors that are included by the element descriptors
    public func remove<T>(_ elements: [T]) where T: RemoteDataDescriptable {
        elements.forEach { element in
            if let elementDescriptor = element.descriptor {
                self.descriptors = self.descriptors.filter {
                    if elementDescriptor.includes($0) {
                        return false
                    }
                    return true
                }
            }
        }
    }

    /// Filter any elements whose descriptor matches one in the set (with matcher)
    public func filter<T>(_ elements: [T], with matcher: (RemoteDataDescriptor, RemoteDataDescriptor) -> Bool = RemoteDataDescriptor.includes) -> [T] where T: RemoteDataDescriptable {
        return elements.filter { element in
            if let elementDescriptor = element.descriptor {
                if self.descriptors.contains(where: { matcher($0, elementDescriptor) }) {
                    return false
                }
            }
            return true
        }
    }

    /// Reset cache and remove all descriptors
    public func reset() {
        descriptors.removeAll()
    }

}

extension RemoteDataDescriptorCache: TidepoolRemoteDataInsertDelegate {

    func insert(data: TidepoolRemoteData) {
        insert(data.stored)
        insert(data.deleted)
    }

}

extension RemoteDataDescriptorCache: TidepoolRemoteDataRemoveDelegate {

    func remove(data: TidepoolRemoteData) {
        remove(data.stored)
        remove(data.deleted)
    }

}

extension RemoteDataDescriptorCache: TidepoolRemoteDataFilterDelegate {

    func filter(data: TidepoolRemoteData) -> TidepoolRemoteData {
        return TidepoolRemoteData(stored: filter(data.stored), deleted: filter(data.deleted))
    }

}
