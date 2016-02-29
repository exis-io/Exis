#####################################TEST######################################
Backend leaves properly

$scope.$on("$riffle.leave", function() {
    assert(true, "On Leave Triggered");
});

$riffle.register("testBackendLeave", $riffle.want(function(s) {
    $riffle.leave()
    return "Leaving";
}, String));
