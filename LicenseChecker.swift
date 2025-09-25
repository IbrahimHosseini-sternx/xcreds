//
//  LicenseChecker.swift
//  XCreds
//
//

import Cocoa

class LicenseChecker: NSObject {
    enum LicenseState {
        case valid(Int)
        case invalid
        case trial(Int)
        case trialExpired
        case expired

    }

    func currentLicenseState() -> LicenseState {
        let trialDays = 14

        if UserDefaults.standard.value(forKey: "tts") == nil {
            UserDefaults.standard.setValue(Date(), forKey: "tts")
        }
        let firstLaunchDate = UserDefaults.standard.value(forKey: "tts") as? Date

        var trialState = LicenseState.trialExpired
        if let firstLaunchDate = firstLaunchDate {
            let secondsPassed = Date().timeIntervalSince(firstLaunchDate)
            let trialDaysLeft=trialDays-(Int(secondsPassed)/(24*60*60));

            if secondsPassed<Double(24*60*60*trialDays) {
                trialState = .trial(trialDaysLeft)
            }

        }
        else {
            TCSLogErrorWithMark("did not get first launch date")
        }
        let check = TCSLicenseCheck()
        let status = check.checkLicenseStatus("so.trio.xcreds", withExtension: "")
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFractionalSeconds, .withFullDate]

        switch status {

        case .valid:
            if let dateExpiredString = check.license.dateExpired,let dateExpires = dateFormatter.date(from:dateExpiredString ){

                return .valid(Int(dateExpires.timeIntervalSinceNow))
            }

            return .valid(0)
        case .expired:
            return trialState

        case .invalid:
            return LicenseState.invalid
        case .unset:
            return trialState
        default:
            return trialState
        }

    }

}
