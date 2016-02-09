import Riffle

class TourSubBackend: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        /////////////////////////////////////////////////////////////////////////////////////
        // Example Tour Pub/Sub Lesson 1 - our first basic example
        backend.publish("myFirstSub", "Hello")
        // End Example Tour Pub/Sub Lesson 1

        /////////////////////////////////////////////////////////////////////////////////////
        // Example Tour Pub/Sub Lesson 2 Works - type enforcement good
        backend.publish("iWantStrings", "Hi")
        // End Example Tour Pub/Sub Lesson 2 Works

        // Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
        backend.publish("iWantInts", "Hi")
        // End Example Tour Pub/Sub Lesson 2 Fails

        print("___SETUPCOMPLETE___")
    }

    override func onLeave() {
        print("Receiver left!")
    }
}
