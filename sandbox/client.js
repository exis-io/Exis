var riffle = require('jsriffle');
riffle.setDevFabric();
console.log("Starting client")

var connection = new riffle.Connection('xs.damouse.frontend');


connection.onJoin = function (session) {
    console.log("Connection opened");

    session.publish('xs.damouse.backend/sub', ["Hello!"]);

    session.call('xs.damouse.backend/register', []).then(
      function (res) {
         console.log("Call success: ", res);
      }
   );
};


connection.join();
