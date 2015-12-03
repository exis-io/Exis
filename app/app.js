'use strict';


// Declare app level module which depends on views, and components
angular.module('myApp', [
  'ngRoute',
  'myApp.view1',
  'myApp.view2',
  'myApp.version',
  "vxWamp"
]).

config(['$routeProvider', function($routeProvider) {
  $routeProvider.otherwise({redirectTo: '/view1'});
}])

.config(function($wampProvider) {
    $wampProvider.init({
        url: 'ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws',
        realm: 'xs.demo.angular'
    });
})
.run(function($wamp){
    $wamp.open();
});
