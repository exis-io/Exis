####TEST####
//Wants a string "Hello" returns string "Hello World"
$riffle.register("regStrStr", $riffle.want(function(s) {
    assert(s === "Hello", "Expected: 'Hello' Got: " + s);
    return "Hello World";
}, String));

####TEST####
//Wants a Number 42 returns a Number 24
$riffle.register("regNumNum", $riffle.want(function(n) {
    assert(n === 42, "Expected: 42 Got: " + n);
    return 24;
}, Number));
