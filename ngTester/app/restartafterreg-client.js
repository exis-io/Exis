#####################################TEST######################################
Restarting after a register works

setTimeout(function (){
    $riffle.call("restartAfterR", "Restart after reg").want(String).then(function(s) {
        var expected = "Restart after reg works";
        assert(s === expected, "Expected: '" + expected + "', Got: " + s + "'");
    });
}, 4000);
