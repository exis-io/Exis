$riffle.register("iWantStrings", $riffle.want(function(s) {
    return "Hello World";
}, String));


$riffle.register("iWantInts", $riffle.want(function(s) {
    return "Hello World";
}, Number));

####TEST####
//Wants a string returns string "Hello World"



####TEST####
//Wants a Number 42 returns a Number 24
$riffle.register("regNumNum", $riffle.want(function(n) {
    assert(n === 42, "Expected: 42 Got: " + n);
    return 24;
}, Number));
