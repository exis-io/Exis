####TEST####
/* Tests register/call type enforcement when we have correct type works*/
$riffle.call("t1", "Hi").want(String).then(function (s) {
    assert(s === "Hello World", "Expected: 'Hello World' Got: " + s);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});


####TEST####
/* Tests register/call, type enforcement with incorrect type throws exception */
$riffle.call("t2", "Hi").want(String).then(function (s) {
    assert(false, "Expected: Exception when calling a function that wants ints.);
},
function (err) {
    assert(true, "Expected: TypeError Got: " + err);
});


####TEST####
/* Tests register/call, type enforcement on want works correctly */
$riffle.call("iWantStrings", "Hi").want(String).then(function (s) {
    assert(false, "Expected: Exception when calling a function that wants ints.);
},
function (err) {
    assert(true, "Expected: TypeError Got: " + err);
});









####TEST####
//calls with number 42 expects number 24
$riffle.call("regNumNum", 42).want(Number).then(function (n) {
    assert(n === 24, "Expected: 24 Got: " + n);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});
