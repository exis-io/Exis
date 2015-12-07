# Cards Against Demo

Demo application showcasing applications written with Exis. 

Client applications communicate with a *backend*, or remotely running program, that manages global game state. The backend creates a set of *rooms* that each host a game. For this application the backend is called *gamelogic*.

Communication between clients and the backend is not limited to specific languages. As of this writing the reference implementation of the backend is written in swift. 

## API

The client side libraries automatically transform model objects for transfer across the fabric as long as they're subclasses of `RiffleModel`. `User` is the only model object in *CardsAgainst*. Here what it looks like. 

```text
User(RiffleModel)
    string domain
    int score
    bool czar
```


Players are not given a room to begin with. They have to request a room  assignment by calling `play`. Note that the room receives the name of the caller as a `#details` registration.

```
Endpoint:   gamelogic/play
Verb:       call
Arguments:  None
Returns:    [string] cards, [Player] players, string state, string roomName
```

To isolate the rooms from one another they expose their functionality using dynamically constructed endpoints. The name of the room, as returned in the function above, replaces the `$` in the calls below. For example, with an endpoint `/$/ping` a room called `first` exposes: `/first/ping`.

Tell the room the user picked a card. This is a `#details` registration: room also receives the name of the caller.

```
Endpoint:   gamelogic/$/pick
Verb:       call
Arguments:  None
Returns:    [string] cards, [Player] players, string state, string roomName
```

Leave this room:

```
Endpoint:   gamelogic/$/leave
Verb:       call
Arguments:  None
Returns:    None
```

Clients should subscribe to the next three endpoints. The room publishes on these endpoints when a new phase of the round begins. Each round, a question is presented to the room and a new player is elected as the `czar`. The rest of the players pick answer cards from their hand that best answers the question and the czar picks the funniest card from the bunch. Each round consists of three phases: `answering`, `picking`, and `scoring`. 

Published at the start of a new answering phase. Clients can not call `/pick` to choose a card. 

```
Endpoint:   gamelogic/$/answering
Verb:       publish
Arguments:  Player currentCzar, string currentQuestion, int roundDuration
```

Published at the start of a new picking phase. The czar can call `pick` to choose a winner. 

```
Endpoint:   gamelogic/$/picking
Verb:       publish
Arguments:  [string] allAnswers, int roundDuration
```

Published at the start of a new scoring phase. Clients can't do anything here-- this phase is just dead time between rounds so the clients can update their UI and see the winning card.

```
Endpoint:   gamelogic/$/scoring
Verb:       publish
Arguments:  Player winner, string winningCard, int roundDuration
```

Rooms publish to this endpoint when players leave the room. 

```
Endpoint:   gamelogic/$/left
Verb:       publish
Arguments:  Player leavingPlayer
```

Rooms publish to this endpoint when players join the room. 

```
Endpoint:   gamelogic/$/joined
Verb:       call
Arguments:  Player newPlayer
```

Each player registers this call to receive a new card at the end of each round. These calls are registered on the player's domain-- substitute the name of of the client for these.

```
Endpoint:   {userdomain}/draw
Verb:       call
Arguments:  None
Returns:    [string] cards
```
