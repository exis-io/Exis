#####################################TEST######################################
1. Client leaves properly

$scope.$on("$riffle.leave", function() {
    assert(true, "On Leave Triggered"); 
});
$riffle.call("testClientLeave", "Leave").want(String).then(function (s) {
    $riffle.leave();
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});
