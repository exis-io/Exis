#####################################TEST######################################
Restarting after a register works

$riffle.register("restartAfterR", $riffle.want(function(s) {
    var expected = "Restart after reg";
    assert(s === expected, "Expected: '" + expected + "', Got: '" + s + "'");
    return s + " works";
}, String));

setTimeout(function (){
    console.log("___NODERESTART___");
}, 1000);
