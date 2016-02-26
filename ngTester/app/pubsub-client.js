#####################################TEST######################################
Lesson 1.1: Basic pubsub works

$riffle.publish("myFirstSub", "Hello").then(function() {
    assert(true, "Publish to iWantStrings completes");
},
function (err) {
    assert(false, "Exception while publishing: " + err);
});

#####################################TEST######################################
Lesson 2.1: Pubsub works when sending correct value

$riffle.publish("iWantStrings", "Hi").then(function() {
    assert(true, "Publish to iWantStrings completes");
},
function (err) {
    assert(false, "Exception while publishing: " + err);
});


#####################################TEST######################################
Lesson 2.2: Pubsub doesnt go through when incorrect type

$riffle.publish("iWantInts", "Hi").then(function () {
    assert(true, "Publish to iWantInts completes");
},
function (err) {
    assert(false, "Received exception: " + err);
});
