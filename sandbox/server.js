var riffle = require('jsriffle');
riffle.setDevFabric();
console.log("Starting server")

var connection = new riffle.Connection('xs.damouse.backend');

function onevent(args) {
  console.log("Event:", args[0]);
};

connection.onJoin = function (session) {
    console.log("Connection opened");
    
    session.subscribe('xs.damouse.backend/sub', onevent).then(
      function (registration) {
         console.log("Subscription registered:", registration.id);
      },
      function (error) {
         console.log("Registration failed:", error);
      }
   );

   function utcnow() {
      console.log("Call receive");
      now = new Date();
      return now.toISOString();
   };

   session.register('xs.damouse.backend/register', utcnow).then(
      function (registration) {
         console.log("Procedure registered:", registration.id);
      },
      function (error) {
         console.log("Registration failed:", error);
      }
   );
};

var domain = new riffle.Domain("xs.demo");

// var s = d.subdomain("bob");

domain.onJoin = function() {
    console.log("Domain override join");
    this.subscribe();
};

domain.join();

// connection.join();