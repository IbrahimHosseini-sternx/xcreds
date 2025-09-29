//
//

@available(macOS, deprecated: 11)
class TrioXLoginDone: TrioXBaseMechanism {

    override init(mechanism: UnsafePointer<MechanismRecord>) {
        super.init(mechanism: mechanism)
    }

    @objc override func run() {
        TCSLogWithMark("TrioXLoginDone mech starting")

        let isAccountCreationPending = getHint(type: .isAccountCreationPending) as? Bool ?? false

        if isAccountCreationPending==true {
            TCSLogWithMark("isAccountCreationPending==true")
        }
        else {
            TCSLogWithMark("isAccountCreationPending==false")
        }
        if isAccountCreationPending == false {
            TCSLogWithMark("Hiding background")
            for window in NSApp.windows {
                window.close()
            }
        }
        else {
            TCSLogWithMark("Not hiding progress indicator to avoid black screen")
        }
        allowLogin()

    }
    @objc func tearDown() {
        TCSLogWithMark("Got teardown request in TrioXLoginDone")

    }

}
