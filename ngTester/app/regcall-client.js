#####################################TEST######################################
1. Basic example

$riffle.call("myFirstFunc", "Hello").want(String).then(function (s) {
    var expected = "Hello World";
    assert(s === expected, "Expected: '" + expected + "', Got: " + expected);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});

#####################################TEST######################################
2. Reg call with correct type

$riffle.call("iWantStrings", "Hi").want(String).then(function (s) {
    var expected = "Thanks for saying Hi";
    assert(s === expected, "Expected: '" + expected + "', Got: " + expected);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});

#####################################TEST######################################
3. Calling a function with wrong type fails

$riffle.call("iWantInts", "test").want(String).then(function (s) {
    assert(false, "call shouldn't have gone through");
},
function (err) {
    var expected = "wamp.error.invalid_argument: Cumin: expecting primitive float, got string";
    assert(err === expected, "Expected: '" + expected + "', Got: " + err);
});

#####################################TEST######################################
4. Receiving a function with wrong want throws exception

$riffle.call("iGiveInts", "Hi").want(String).then(function (s) {
    assert(false, "shouldnt have received a number properly")
},
function (err) {
    var expected = "Cumin: expecting primitive str, got int";
    assert(err === expected, "Expected: '" + expected + "', Got: " + err);
});

#####################################TEST######################################
5. Receiving list of strings works properly
    
$riffle.call("iWantManyStrings", ["This", "is", "cool"]).want(String).then(function (s) {
    var expected = "Thanks for 3 strings!"
    assert(s === expected, "Expected: '" + expected + "', Got: " + expected) 
},
function (err) {
    assert(false, "Shouldnt have received error: " + err); 
});


#####################################TEST######################################
6. Sending multiple types when backend only wants ints

$riffle.call("iWantManyInts", [0, 1, "two"]).want(String).then(function (s) {
    assert(false, "call shouldn't have gone through");
},
function (err) {
    var expected = "Cumin: expecting primitive float, got string";
    assert(err === expected, "Expected: '" + expected + "', Got: " + err);
});

#####################################TEST######################################
7. Sending classes using riffle works properly
## shouldnt receive call ##

function Student() {
    this.name = "Student Name";
    this.age = 20;
    this.studentID = 0;
}
var s = new Student();
s.name = "John Smith";
s.age = 18;
s.studentID = 1234;
$riffle.call("sendStudent", s).then(function () {
},
function (err) {
    assert(false, "shouldnt have received response");
});
