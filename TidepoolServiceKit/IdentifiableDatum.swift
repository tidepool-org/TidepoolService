//
//  IdentifiableDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/19/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import TidepoolKit

protocol TypedDatum {
    static var resolvedType: String { get }
}

protocol IdentifiableDatum {
    var syncIdentifierAsString: String { get }
}

extension IdentifiableDatum {
    func datumId(for userId: String) -> String {
        return datumId(for: userId, resolvedIdentifier: resolvedIdentifier)
    }

    func datumId<T: TypedDatum>(for userId: String, type: T.Type) -> String {
        return datumId(for: userId, resolvedIdentifier: resolvedIdentifier(for: type))
    }

    private func datumId(for userId: String, resolvedIdentifier: String) -> String {
        return "\(userId):\(resolvedIdentifier)".md5hash!
    }

    var datumOrigin: TOrigin {
        return datumOrigin(for: resolvedIdentifier)
    }

    func datumOrigin<T: TypedDatum>(for type: T.Type) -> TOrigin {
        return datumOrigin(for: resolvedIdentifier(for: type))
    }

    private func datumOrigin(for resolvedIdentifier: String) -> TOrigin {
        return TOrigin(id: resolvedIdentifier,
                       name: Bundle.main.bundleIdentifier,
                       version: Bundle.main.semanticVersion,
                       type: .application)
    }

    var resolvedIdentifier: String {
        return syncIdentifierAsString
    }

    func resolvedIdentifier<T: TypedDatum>(for type: T.Type) -> String {
        return "\(resolvedIdentifier):\(type.resolvedType)"
    }
}
