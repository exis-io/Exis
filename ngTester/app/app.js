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
    
    function removeFromResults(index, color, result, description, message) {
      var result = "<p id=success_" + index + " style='color:" + color + ";'>" + result + " - " + description + " - ";
      var i = -1;
      for (var j in $scope.results) {
        var displayedTestResult = $sce.getTrustedHtml($scope.results[j]);
        if (result.startsWith(displayedTestResult) {
          i = j;
        }
      }
      if (i > -1) {
        $scope.results.splice(i, 1); 
      }
    }

    function assertBuilder(index){
      return function(condition, message, whichReceiver){
        if (typeof whichReceiver  === "undefined") {
          whichReceiver = 0;
        }

        /*
         * Find the specific test from the index
         * Use the receiver to find the specific receiver
        */

        // Every time we receive a call here, we need to check
        var description = tests[index][1];
        var results = tests[index][2];
        var receiver = results[whichReceiver];

        receiver['beenCalled'] = true;
        receiver['callResult'] = condition;
        receiver['message'] = message;
        
        var correctTest = true;

        for (var r in results) {
            
        }

        var color = "red";
        var result = "FAILED"; 

        // If we weren't supposed to receive call, we need to remove old rule
        if (tests[index][2]) {
          removeFromResults(index, "green", "SUCCESS", description, "didn't receive a call!");
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
      // String constants to look for
      var defaultDontReceiveString = "## shouldnt receive call ##";
      var specificDontReceiveString = "## shouldnt receive call on endpoints: ";
      var multipleReceiversString = "## multiple receivers: ";

      // Split each test using this string
      code = resp.data.split("#####################################TEST######################################\n");
      // Remove the first test if empty
      if(code[0] === ""){
        code.shift();
      }

      // Log the code we are executing to the console
      for(var i in code){

        var testDescription = "";
        // Holds the number reg/sub functions which can receive input
        // Default is 1 when not specified, because most tests have that
        var numReceivers = 1;

        // Set if we expect to not be called 
        // Endpoints are the specific reg/subs which shouldnt be called
        // Defaults to 0 if one endpoint, otherwise could be multiple endpoints
        var dontReceiveCall = false;
        var dontReceiveEndpoints = [];
        var actualCode = code[i];

        // Holds the first line of input, used to check for description, multiple receivers, dont call, etc.
        var firstLine = "";
        // Get the test description (this is always the first line)
        var testDescription = actualCode.split('\n')[0];
        actualCode = actualCode.substring(testDescription.length + 1);

        
        // Check if we have multiple receivers
        firstLine = actualCode.split('\n')[0];
        if (firstLine === multipleReceivers) {
            numReceivers = parseInt(firstLine.substring(multipleReceiversString.length));
            console.log(numReceivers);
            actualCode = actualCode.substring(firstLine.length + 1);
        }

        // Check if we are actually expecting a call
        firstLine = actualCode.split('\n')[0];
        if (firstLine === defaultDontReceiveString) {
            dontReceiveEndpoints = [0];
            actualCode = actualCode.substring(firstLine.length + 1);
        }
        else if (firstLine.startsWith(specificDontReceiveString)) {
            //Need to get the specific  
            dontReceiveEndpoints = eval(firstLine.substring(specificDontReceiveString.length));
            actualCode = actualCode.substring(firstLine.length + 1);
        }

        if (dontReceiveCall) {
          // Add a success to results, only will switch to failure if called
          addToResults(i, "green", "SUCCESS", testDescription, "didn't receive a call!");
          actualCode = actualCode.substring(firstLine.length + 1);
        }

        /*
         * We need to store a list which holds data for each receiver.
         * Each receiver should have two values:
         *      shouldReceive: bool
         *      didReceive: bool
        */
        var results = [];
        var i;
        for ( i = 0; i < numReceivers; i++) {
            receiver = {}
            // We have a successful receiver when we haven't been called and we shouldn't receive a call
            // OR when we have been called, assert is true, and we should receive call
            receiver['beenCalled'] = false;
            receiver['shouldReceiveCall'] = (dontReceiveEndpoints.indexOf(i) > -1)
            receiver['message'] = "didn't receive a call";
            results.push(receiver);
        }

        tests.push([new Function('$riffle', 'assert', actualCode), testDescription, results]);
      }
      runTests();
    }

  });
