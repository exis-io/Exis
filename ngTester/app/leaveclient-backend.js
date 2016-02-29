#####################################TEST######################################
1. Client leaves properly

$riffle.register("testClientLeave", $riffle.want(function(s) {
    var expected = "Leave";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return "Leaving";
}, String));
