#####################################TEST######################################
Restarting before call works

console.log("___NODERESTART___");
setTimeout(function (){
    $riffle.call("restartBeforeC", "Restart before call").want(String).then(function(s) {
        var expected = "Restart before call works";
        assert(s === expected, "Expected: '" + expected + "', Got: " + s + "'");
    });
}, 6000);
