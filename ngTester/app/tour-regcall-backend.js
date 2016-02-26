$riffle.register("iWantStrings", $riffle.want(function(s) {
    assert(s === "Hello", "Expected: 'Hello', Got: " + s)
    return "Hello World";
}, String));


$riffle.register("iWantInts", $riffle.want(function(s) {
    return "Hello World";
}, Number));

