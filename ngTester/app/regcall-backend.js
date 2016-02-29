#####################################TEST######################################
1. Basic example

$riffle.register("myFirstFunc", $riffle.want(function(s) {
    var expected = "Hello";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return "Hello World";
}, String));


#####################################TEST######################################
2. Reg call with correct type

$riffle.register("iWantStrings", $riffle.want(function(s) {
    var expected = "Hi";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return "Thanks for saying " + s;
}, String));

#####################################TEST######################################
3. Calling a function with wrong type fails
## shouldnt receive call ##

$riffle.register("iWantInts", $riffle.want(function(i) {
    assert(false, "shouldnt have received a call");
    return "Thanks for sending int " + i;
}, Number));
    

#####################################TEST######################################
4. Receiving a function with wrong want throws exception

$riffle.register("iGiveInts", $riffle.want(function(s) {
    var expected = "Hi";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return 42;
}, String));
    

#####################################TEST######################################
5. Receiving list of strings works properly

$riffle.register("iWantManyStrings", $riffle.want(function(s) {
    var expected = "This is cool";
    var joined = s.join(" "); // Expects a String, like "This is cool"
    assert(joined === expected, "Expected: '" + expected + "', Got: " + joined)
    return "Thanks for " + s.length + " strings!"
}, [String]));
    

#####################################TEST######################################
6. Sending multiple types when backend only wants ints
## shouldnt receive call ##

$riffle.register("iWantManyInts", $riffle.want(function(s) {
    assert(false, "shouldnt have received a call");
    return "Thanks for " + s.length + " ints!"
}, [Number]));

#####################################TEST######################################
Reg-backend 1: Example reg/call str str

$riffle.register("regStrStr", $riffle.want(function(s) {
    var expected = "Hello";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return "Hello World";
}, String));

#####################################TEST######################################
Reg-backend 2: Example reg/call str int

$riffle.register("regStrInt", $riffle.want(function(s) {
    var expected = "Hello";
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return 42;
}, String));

#####################################TEST######################################
Reg-backend 3: Example reg/call int str

$riffle.register("regIntStr", $riffle.want(function(s) {
    var expected = 42;
    assert(s === expected, "Expected: '" + expected + "', Got: " + s)
    return "Hello World";
}, Number));
    

#####################################TEST######################################
7. Sending classes using riffle works properly

function Student() {
    this.name = String;
    this.age = Number;
    this.studentID = Number;
}

Student.prototype.toString = function() {
    return this.name + ", Age: " + this.age + ", ID: " + this.studentID;
};

$riffle.register("sendStudent", $riffle.want(function(s) {
    var expected = "John Smith, Age: 18, ID: 1234";
    var actual = s.toString();
    assert(actual === expected, "Expected: '" + expected + "', Got: " + actual);
}, $riffle.modelObject(Student)));
