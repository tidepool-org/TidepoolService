//
//  IdentifiableHKDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/15/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import TidepoolKit

protocol IdentifiableHKDatum {
    var provenanceIdentifier: String { get }
    var syncIdentifier: String? { get }
    var uuid: UUID? { get }
}

extension IdentifiableHKDatum {
    func datumId(for userId: String) -> String? {
        return datumId(for: userId, resolvedIdentifier: resolvedIdentifier)
    }

    func datumId<T: TypedDatum>(for userId: String, type: T.Type) -> String? {
        return datumId(for: userId, resolvedIdentifier: resolvedIdentifier(for: type))
    }

    private func datumId(for userId: String, resolvedIdentifier: String?) -> String? {
        guard let resolvedIdentifier = resolvedIdentifier else {
            return nil
        }
        return "\(userId):\(resolvedIdentifier)".md5hash
    }

//    var datumOrigin: TOrigin? {
//        return datumOrigin(for: resolvedIdentifier)
//    }
//
//    func datumOrigin<T: TypedDatum>(for type: T.Type) -> TOrigin? {
//        return datumOrigin(for: resolvedIdentifier(for: type))
//    }

    func datumOrigin(for resolvedIdentifier: String?, hostIdentifier: String, hostVersion: String) -> TOrigin? {
        guard let resolvedIdentifier = resolvedIdentifier else {
            return nil
        }
        if !provenanceIdentifier.isEmpty, provenanceIdentifier != hostIdentifier {
            return TOrigin(id: resolvedIdentifier,
                           name: provenanceIdentifier,
                           type: .application)
        } else {
            return TOrigin(id: resolvedIdentifier,
                           name: hostIdentifier,
                           version: hostVersion,
                           type: .application)
        }
    }

    var datumSelector: TDatum.Selector? {
        return datumSelector(for: resolvedIdentifier)
    }

    func datumSelector<T: TypedDatum>(for type: T.Type) -> TDatum.Selector? {
        return datumSelector(for: resolvedIdentifier(for: type))
    }

    private func datumSelector(for resolvedIdentifier: String?) -> TDatum.Selector? {
        guard let resolvedIdentifier = resolvedIdentifier else {
            return nil
        }
        return TDatum.Selector(origin: TDatum.Selector.Origin(id: resolvedIdentifier))
    }

    var resolvedIdentifier: String? {
        var resolvedIdentifier: String?

        // The Tidepool backend requires a unique identifier for each datum that does not change from creation
        // through updates to deletion. Since some objects do not inherently have such a unique identifier,
        // we can generate one based upon the HealthKit provenance identifier (the unique source identifier of
        // the object, namely the bundle identifier) plus the HealthKit sync identifier.
        //
        // However, while all objects created within Loop are guaranteed to have a HealthKit sync identifier, this
        // is not true for objects created outside of Loop. In this case, we fall back to using the HealthKit UUID.
        // This works because any HealthKit objects without a sync identifier CANNOT be updated, by definition,
        // (only created and deleted) and the UUID is constant for this use case.
        if !provenanceIdentifier.isEmpty {
            if let syncIdentifier = syncIdentifier, !syncIdentifier.isEmpty {
                resolvedIdentifier = "provenanceIdentifier:\(provenanceIdentifier):syncIdentifier:\(syncIdentifier)"
            } else if let uuid = uuid {
                resolvedIdentifier = "provenanceIdentifier:\(provenanceIdentifier):uuid:\(uuid.uuidString)"
            }
        } else {

            // DEPRECATED: Backwards compatibility (DIY)
            // For previously existing objects created outside of Loop we do not have a provenance identifier and
            // we cannot rely on the sync identifier (since it is scoped by the provenance identifier). Therefore,
            // just fallback to use the UUID.
            if let uuid = uuid {
                resolvedIdentifier = "uuid:\(uuid.uuidString)"
            }
        }

        // Finally, assuming we have a valid string, MD5 hash the string to yield a nice identifier
        return resolvedIdentifier?.md5hash
    }

    func resolvedIdentifier<T: TypedDatum>(for type: T.Type) -> String? {
        guard let resolvedIdentifier = resolvedIdentifier else {
            return nil
        }
        return "\(resolvedIdentifier):\(type.resolvedType)"
    }
}
