#####################################TEST######################################
Reg call with correct type

$riffle.register("iWantStrings", $riffle.want(function(s) {
    assert(s === "Hello", "Expected: 'Hello', Got: " + s)
    return "Hello World";
}, String));

#####################################TEST######################################
Calling a function with wrong type fails
## shouldnt receive call ##

$riffle.register("iWantInts", $riffle.want(function(i) {
    assert(false, "shouldnt have received a call");
    return "Thanks for sending int " + i;
}, Number));
