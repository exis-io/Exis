# swiftRiffle for Ubuntu

This is the open source version of swiftRiffle. 

To build:


1. Clone project, make sure go is installed, and run `python stump.py init`
2. In the top level directory run `make swift`
3. Enter `swift/example`. Edit the third expression in `receiver.swift` and `sender.swift` to change the target fabric. Run `make`.
4. `receiver.swift` registers and subscribes while `sender.swift` calls and publishes. In `swift/example` run `./runreceiver` and `./runsender` to start them.