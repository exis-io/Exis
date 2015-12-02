var riffle = require('riffle');

var connection = new riffle.Connection({
   url: 'ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws',
   realm: 'xs.damouse.backend'}
);

connection.onopen = function (session) {
    console.log("Connection opened");

    session.publish('xs.damouse.frontend/sub', ["Hello!"]);

    session.call('xs.damouse.frontend/register', []).then(
      function (res) {
         console.log("Result:", res);
      }
   );
};

console.log("Starting backend")
connection.open();
