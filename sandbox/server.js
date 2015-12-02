var riffle = require('riffle');

var connection = new riffle.Connection({
   url: 'ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws',
   realm: 'xs.damouse.frontend'}
);

function onevent(args) {
  console.log("Event:", args[0]);
};

connection.onopen = function (session) {
    console.log("Connection opened");
    session.subscribe('xs.damouse.frontend/sub', onevent);

   function utcnow() {
      console.log("Call receive");
      now = new Date();
      return now.toISOString();
   };

   session.register('xs.damouse.frontend/register', utcnow).then(
      function (registration) {
         console.log("Procedure registered:", registration.id);
      },
      function (error) {
         console.log("Registration failed:", error);
      }
   );
};


console.log("Starting frontend")
connection.open();