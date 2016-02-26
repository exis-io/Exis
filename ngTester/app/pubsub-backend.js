#####################################TEST######################################
Lesson 1.1: Basic pubsub works
## multiple receivers: 2 
## shouldnt receive call on endpoints: [1] 


$riffle.subscribe("myFirstSub", $riffle.want(function(s) {
    var expected = "Hello";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s, 0)
}, String));

$riffle.subscribe("myFirstSub", $riffle.want(function(s) {
    var expected = "Hello";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s, 1)
}, Number));


#####################################TEST######################################
Lesson 2.1: Pubsub works when sending correct value

$riffle.subscribe("iWantStrings", $riffle.want(function(s) {
    var expected = "Hi";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
}, String));

#####################################TEST######################################
Lesson 2.2: Pubsub doesnt go through when incorrect type
## shouldnt receive call ##
    
$riffle.subscribe("iWantInts", $riffle.want(function(i) {
    assert(false, "shouldnt have received a publish");
}, Number));


#####################################TEST######################################
Example 1: Very basic pubsub
    
$riffle.subscribe("basicSub", $riffle.want(function(i) {
    var expected = "Hello";
    assert(i === expected, "Expected: '" + expected + "', Got: " + i)
}, String));


#####################################TEST######################################
Example 2: Pubsub sending two different types of data
    
$riffle.subscribe("basicSubTwo", $riffle.want(function(s, i) {
    var expected = "Hello 3";
    var received = [s, i].join(" ");
    assert(received === expected, "Expected: '" + expected + "', Got: " + received)
}, String, Number));

