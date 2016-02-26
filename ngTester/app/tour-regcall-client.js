#####################################TEST######################################
Reg call with correct type

$riffle.call("iWantStrings", "Hello").want(String).then(function (s) {
    assert(s === "Hello World", "Expected: 'Hello World' Got: " + s);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});

#####################################TEST######################################
Calling a function with wrong type fails

$riffle.call("iWantInts", "test").want(String).then(function (s) {
    assert(false, "call shouldn't have gone through");
},
function (err) {
    assert(true, "we received an error about incorrect type.");
});
