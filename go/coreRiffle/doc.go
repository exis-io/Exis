// package coreRiffle allows communciation over the fabric.
//
// See the official WAMP documentation at exis.io for
// more details on the protocol.
// package coreRiffle

// This is an  list of the tests clients should implement

// # NOTE-- these should go into core, not client!
// # Client basically just has to test cumin!

// Noargs- Success
// subscribe()
// publish()
// register()
// call()

//     Fail

// Domain does not exist
// Poorly constructed endpoint

// Primitives- Success
// subscribe(primitive)
// publish(primitive)
// register(primitive)
// call(primitive)

// subscribe(RiffleModel)
// publish(RiffleModel)
// register(RiffleModel)
// call(RiffleModel)

// Collections- Success
// subscribe([])
// publish([])
// register([])
// call([])

// subscribe([primitives])
// publish([primitives])
// register([primitives])
// call([primitives])

// subscribe({})
// publish({})
// register({})
// call({})

// subscribe({primitives: primitives})
// publish({primitives: primitives})
// register({primitives: primitives})
// call({primitives: primitives})