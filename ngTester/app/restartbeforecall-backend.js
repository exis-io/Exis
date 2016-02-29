#####################################TEST######################################
Restarting before call works

$riffle.register("restartBeforeC", $riffle.want(function(s) {
    var expected = "Restart before call";
    assert(s === expected, "Expected: '" + expected + "', Got: '" + s + "'");
    return s + " works";
}, String));
