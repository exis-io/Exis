####TEST####
//calls with "Hello" string expects String "Hello World"
$riffle.call("regStrStr", "Hello").want(String).then(function (s) {
    assert(s === "Hello World", "Expected: 'Hello World' Got: " + s);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});

####TEST####
//calls with number 42 expects number 24
$riffle.call("regNumNum", 42).want(Number).then(function (n) {
    assert(n === 24, "Expected: 24 Got: " + n);
},
function (err) {
    assert(false, "Error: Promise Rejected with: " + err);
});
