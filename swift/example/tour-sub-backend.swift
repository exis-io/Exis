import Riffle

class TourSubBackend: Domain, Delegate {

    override func onJoin() {
        /////////////////////////////////////////////////////////////////////////////////////
        // Example Tour Pub/Sub Lesson 1 - our first basic example
        subscribe("myFirstSub") { (s: String) in
            print("I got \(s)") // Expects a String, like "I got Hello"
        }

        // Somewhere in another file or program...
        subscribe("myFirstSub") { (s: String) in
            print("I got \(s), too!") // Expects a String, like "I got Hello, too!"
        }
        // End Example Tour Pub/Sub Lesson 1

        /////////////////////////////////////////////////////////////////////////////////////
        // Example Tour Pub/Sub Lesson 2 Works - type enforcement good
        subscribe("iWantStrings") { (s: String) in
            print(s) // Expects a String, like "Hi"
        }
        // End Example Tour Pub/Sub Lesson 2 Works

        // Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
        subscribe("iWantInts") { (i: Int) in
            print("You won't see me :)")
        }
        // End Example Tour Pub/Sub Lesson 2 Fails

        print("___SETUPCOMPLETE___")
    }

    override func onLeave() {
        print("Receiver left!")
    }
}
