#####################################TEST######################################
Reg call with correct type

$riffle.register("iWantStrings", $riffle.want(function(s) {
    assert(s === "Hello", "Expected: 'Hello', Got: " + s)
    return "Hello World";
}, String));
/* */
