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
    
    function addToResults(index, color, result, description, message) {
      var result = $sce.trustAsHtml("<p id=success_" + index + " style='color:" + color + ";'>" + result + " - " + description + " - " + message + "</p>");
      $scope.results.push(result);
    }
    
    function removeToResults(index, color, result, description, message) {
      var result = $sce.trustAsHtml("<p id=success_" + index + " style='color:" + color + ";'>" + result + " - " + description + " - " + message + "</p>");
      var i = $scope.results.indexOf(result)
      if (i > -1) {
        $scope.results.splice(i, 1); 
      }
    }

    function assertBuilder(index){
      return function(condition, message){
        var color = "red";
        var result = "FAILED"; 
        var description = tests[index][1];

        // If we weren't supposed to receive call, we need to remove old rule
        if (tests[index][2]) {
          removeFromResults(i, "green", "SUCCESS", description, "didn't receive a call!");
        } else if (condition){
          color = "green";
          result = "SUCCESS";
        }
        addToResults(index, color, result, tests[index][1], message);
      };
    }

    function runTests(){
      for(var i in tests){
        tests[i][0]($riffle, assertBuilder(i));
      }
    }

    function parseTests(resp){
      // Split each test using this string
      code = resp.data.split("#####################################TEST######################################\n");
      // Remove the first test if empty
      if(code[0] === ""){
        code.shift();
      }

      // Log the code we are executing to the console
      for(var i in code){
        var testDescription = code[i].split('\n')[0];
        var codeStart = testDescription.length

        var expectCall = code[i].split('\n')[1];
        var dontReceiveCall = (expectCall === '## shouldnt receive call ##');

        console.log(dontReceiveCall);

        if (dontReceiveCall) {
          // Add a success to results
          // If we receive a call later, we will remove that element from results
          addToResults(i, "green", "SUCCESS", testDescription, "didn't receive a call!");
          codeStart += expectCall.length;
        }

        var actualCode = code[i].substring(codeStart);
        console.log(testDescription);
        tests.push([new Function('$riffle', 'assert', actualCode), testDescription, dontReceiveCall]);
      }
      runTests();
    }

  });
