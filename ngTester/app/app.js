'use strict';

/**
 * @ngdoc overview
 * @name browserTesterApp
 * @description
 * # browserTesterApp
 *
 * Main module of the application.
 */
angular.module('browserTesterApp', ['ngResource', 'ngRoute', 'ngRiffle'])

  .config(function ($routeProvider) {
    $routeProvider
      .when('/:side*', {
        template: '<div ng-repeat="result in results"><div ng-bind-html="result"></div></div>',
        controller: 'MainCtrl',
        controllerAs: 'main'
      })
      .otherwise({
        redirectTo: '/'
      });
  })

  .config(function($riffleProvider){
    $riffleProvider.setFabricLocal();
    $riffleProvider.setDomain('xs.demo.test');
  })
//####CONFIG####

  .controller('MainCtrl', function ($scope, $riffle, $http, $routeParams, $sce) {
    var side = $routeParams.side;
    $http.get(side + ".js").then(parseTests);
    $riffle.join();

    var code = [];
    var tests = [];
    $scope.results = [];
    
    function assertBuilder(index){
      return function(condition, message){
        if(condition){
          var result = $sce.trustAsHtml("<p id=success_" + index + " style='color: green;'>" + message + ": PASSED</p>");
          $scope.results.push(result);
        }else{
          var result = $sce.trustAsHtml("<p id=success_" + index + " style='color: red;'>" + message + ": FAILED</p><p id=reason_" + index + " style='color: brown;'>" + code[index] + "</p>");
          $scope.results.push(result);
        }
      };
    }

    function runTests(){
      for(var i in tests){
        tests[i]($riffle, assertBuilder(i));
      }
    }

    function parseTests(resp){
      // Split each test using this string
      code = resp.data.split('####TEST####');
      // Remove the first test if empty
      if(code[0] === ""){
        code.shift();
      }

      // Log the code we are executing to the console
      console.log(code);
      for(var i in code){
        tests.push(new Function('$riffle', 'assert', code[i]));
      }
      runTests();
    }

  });
