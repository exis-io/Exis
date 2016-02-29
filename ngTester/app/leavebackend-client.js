#####################################TEST######################################
Backend leaves properly

$riffle.call("testBackendLeave", "Leave").want(String).then(function (s) {
    var expected = "Leaving";
    assert(s === expected, "Expected: '" + expected + "', Got: '" + s + "'")
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});
