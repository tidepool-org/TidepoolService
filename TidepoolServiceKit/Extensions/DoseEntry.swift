//
//  DoseEntry.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

//public struct DoseEntry: TimelineValue, Equatable {
//    public let type: DoseType
//    public let startDate: Date
//    public let endDate: Date
//    internal let value: Double
//    public let unit: DoseUnit
//    public let deliveredUnits: Double?
//    public let description: String?       // I think this can be ignore. it is a textual description of what the dose entry is about
//    internal(set) public var syncIdentifier: String?
//
//    /// The scheduled basal rate during this dose entry
//    internal var scheduledBasalRate: HKQuantity?
//
//    public init(suspendDate: Date) {
//        self.init(type: .suspend, startDate: suspendDate, value: 0, unit: .units)
//    }
//
//    public init(resumeDate: Date) {
//        self.init(type: .resume, startDate: resumeDate, value: 0, unit: .units)
//    }
//
//    public init(type: DoseType, startDate: Date, endDate: Date? = nil, value: Double, unit: DoseUnit, deliveredUnits: Double? = nil, description: String? = nil, syncIdentifier: String? = nil, scheduledBasalRate: HKQuantity? = nil) {
//        self.type = type
//        self.startDate = startDate
//        self.endDate = endDate ?? startDate
//        self.value = value
//        self.unit = unit
//        self.deliveredUnits = deliveredUnits
//        self.description = description
//        self.syncIdentifier = syncIdentifier
//        self.scheduledBasalRate = scheduledBasalRate
//    }
//}

extension DoseEntry {
    // TODO: Remember pending suspended status device event datum
    // TODO: Remember last basal to update duration with next basal
    var datum: TDatum? {
        return nil  // TODO: Remove this
    }

    var data: [TDatum] {

        // TODO: Implement

        guard syncIdentifier != nil else {
            return []
        }

        var data: [TDatum] = []

                switch type {
                case .basal:
//        //            datum = TScheduledBasalDatum(time: startDate,
//        //                                         duration: <#T##Int#>,
//        //                                         expectedDuration: <#T##Int?#>,
//        //                                         rate: unitsPerHour,
//        //                                         scheduleName: TidepoolService.defaultScheduleName)
                    break
                case .bolus:
//        //            if let deliveredUnits = deliveredUnits {
//        //                datum = TNormalBolusDatum(time: startDate, normal: deliveredUnits, expectedNormal: programmedUnits)
//        //            } else {
//        //                datum = TNormalBolusDatum(time: startDate, normal: programmedUnits)
//        //            }
//        //            // TODO: This is probably not right for boluses in progress. How do we detect those? When we do, we should
//        //            // remove expectedNormal for those. Does a unfinalized bolus not have a end date different from start date?
                    break
                case .resume:
//        //            // TODO: Find previous suspend and update its duration
//        //            break
                    data.append(TStatusDeviceEventDatum(time: startDate, name: .resumed))
                case .suspend:
                    data.append(TStatusDeviceEventDatum(time: startDate, name: .suspended))
//        //            datum = TSuspendedBasalDatum(time: <#T##Date#>, duration: <#T##Int#>, expectedDuration: <#T##Int?#>, suppressed: <#T##TScheduledBasalDatum.Suppressed#>)
//        //            // TODO: TSuspendedBasalDatum?
                    break
                case .tempBasal:
//        //            datum = TAutomatedBasalDatum(time: startDate,
//        //                                         duration: <#T##Int#>,
//        //                                         expectedDuration: <#T##Int?#>,
//        //                                         rate: unitsPerHour)
                    break
                }

        return data.map { $0.adorn(withOrigin: datumOrigin) }
    }

    private var datumOrigin: TOrigin? {
        guard let syncIdentifier = syncIdentifier else {
            return nil
        }
        return TOrigin(id: syncIdentifier)
    }
}

/*
Gerrit Niezen
1: If a pump is suspended at the time of upload, does Uploader send a deviceEvent/status with status of suspended and a duration of 0 (since there is no calculable duration)? If not, what does it send?
A: Yes, and it is annotated with status/incomplete-tuple .

2: If, subsequently, the pump is resumed, does Uploader resend (update) that previous datum (from #1) and change the duration field to the delta between the resume and suspend times?
A: This is what Jellyfish does, so when I changed the Tandem code to run on platform (which is now on a very stale branch with no line of sight to merging)
   I had to write code to pull the last basal and device events from the backend and update them with the new durations, yes.

3: For any suspend/resume case, when would the expectedDuration field in the deviceEvent/status ever be used?
A: I couldn't think of any, but just found this in the docs: https://next.stoplight.io/tidepool/tidepoolapi/version%2F1.0/main.hub.yml?view=%2Fdevice-data%2Fdata-types%2Fdevice-event%2Fstatus#expected-duration-expectedduration

4: For any suspend/resume case, what is stored, if anything, in the reason field?
A: Either automatic, or manual.

5: When is a basal/suspend datum sent? At both suspend and resume? If at suspend, then would duration initially be 0 and then subsequently updated when resumed (like #2 above)? Or just at resume when the duration is known?
A: Like #2, initially 0 and then updated on resume. Also, annotated with basal/unknown-duration , until we get the duration.

Basically, I'm trying to figure how to duplicate how Uploader is stringing together basal and suspend/resume events so that it just works in Tidepool Web.
A: The reason why this is not really an issue with the current pumps that upload to platform, is that even for those with delta uploads,
   there is some amount of overlap so that the last data from the previous upload get updated in any case. (edited)
*/

/*
- when receiving a suspend dose
   - create a deeviceEvent/status
        - status = suspended
        - duration = 0
        - annonated with "status/incomplete-tuple"
   - create a basal/suspended
        - duration = 0
- when receive a resume dose
    - find previous deviceEvent/status
        - ensure it is status == suspended
        - update duration to delta between new.startDate - old.startDate
- when receive a basal event
    - find previous basal
        - update duration to delta between new.startDate - old.startDate, may already be the same
    - create new basal/scheduled
        - duration = endDate - startDate
 - when receive a temp basal event
    - find previous basal
        - update duration to delta between new.startDate - old.startDate, may already be the same
    - create new basal/automated
        - duration = endDate - startDate


- does bolus use end date?


DoseEntry
- type: .bolus
    startDate
    value
    units
- type: .tempBasal
    ???
- type: .suspend
    startDate
    value = 0
    units = .units
- type: .resume
    startDate
    value = 0
    units = .units


- tempBasal *MAY* require a scheduledBasalRate (it may be what distinguishes scheduled basal from temp basal in HK)


Q: looks like temp basal records delivered units too
Q: is programmedTempBasalRate on .basal events, too? It must be or logic doesn't work
Q: what is description used for?

How are CachedInsulingDeliveryObjects created?

Consider checking end date if past now, if so then set to 0? or now - start date?

Gerrit - bolus `time` field is start or end of bolus delivery? What if in progress when uploading?


 */
