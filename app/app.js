'use strict';


// Declare app level module which depends on views, and components
angular.module('myApp', [
  'ngRoute',
  'myApp.view1',
  'myApp.view2',
  'myApp.version',
  "ngRiffle"
]).

config(['$routeProvider', function($routeProvider) {
  $routeProvider.otherwise({redirectTo: '/view1'});
}])

.config(function($riffleProvider) {
    $riffleProvider.init("xs.demo.ng");
})
.run(function($riffle){
    $riffle.open();
});
