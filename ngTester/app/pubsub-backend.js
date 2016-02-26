#####################################TEST######################################
Lesson 1.1: Basic pubsub works
## multiple receivers: 2 

$riffle.subscribe("myFirstSub", $riffle.want(function(s) {
    var expected = "Hello";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s, 0)
}, String));

$riffle.subscribe("myFirstSub", $riffle.want(function(s) {
    var expected = "Hllo";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s, 1)
}, String));


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
