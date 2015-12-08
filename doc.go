// package core allows communciation over the fabric.
//
// See the official WAMP documentation at exis.io for
// more details on the protocol.
package core

/* This is an  list of the tests clients should implement

# NOTE-- these should go into core, not client!
# Client just had to test Cumin and threading implementation.

Noargs
    Success

        subscribe()
        publish()
        register()
        call()

    Failure

        Domain does not exist
        Poorly constructed endpoint
        Incorrect number of arguments
        Incorrect types of arguments
        Timeout error (?)
        What happens when a called function throws into a caller?

Primitives

        subscribe(primitive)
        publish(primitive)
        register(primitive)
        call(primitive)

Models

        subscribe(RiffleModel)
        publish(RiffleModel)
        register(RiffleModel)
        call(RiffleModel)

Collections- Success

        subscribe([])
        publish([])
        register([])
        call([])

        subscribe([primitives])
        publish([primitives])
        register([primitives])
        call([primitives])

        subscribe({})
        publish({})
        register({})
        call({})

        subscribe({primitives: primitives})
        publish({primitives: primitives})
        register({primitives: primitives})
        call({primitives: primitives})

*/
