'use strict';

angular.module('myApp.view1', ['ngRoute'])

.config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/view1', {
    templateUrl: 'view1/view1.html',
    controller: 'View1Ctrl'
  });
}])

.controller('View1Ctrl', function($scope, $wamp) {

    $wamp.register('xs.demo.angular/register', function(args) {
        console.log("Ng received call: " + args[0] + args[1])
    });

    $wamp.subscribe('xs.demo.angular/sub', function(args) {
        console.log("Ng received publish: " + args[0] + args[1])
    });

    $wamp.publish('xs.demo.server/sub', 'Hello', 'world!');

    $wamp.call('xs.demo.server/register', 'Ping, ', 'you dog');
      

   $scope.$on("$wamp.open", function (event, session) {
        console.log('We are connected to the WAMP Router!'); 
    });

    $scope.$on("$wamp.close", function (event, data) {
        $scope.reason = data.reason;
        $scope.details = data.details;
    });
});