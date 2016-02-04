// Example Want Definitions Models - all definitions for riffle.Models
// ARBITER set action defs

// In NodeJS you must import jsriffle:
var riffle = require('jsriffle');

// Declare a User class
function User() {
    this.name = "default";
}
// define a function that is only called
// if a User is passed:
this.register("endpoint",
    riffle.want(function(u) {...}, riffle.ModelObject(User))
);
// call a function, send a User, expect a User back
var u = new User();
u.name = "This guy";
backend.call("get_user", u).then(
    riffle.wait(function(otherU) {...}, riffle.ModelObject(User))
);

// A basic model of a Student
function Student() {
    this.first = "firstName";
    this.last = "lastName";
    this.grade = 0;
}
// Expect a Student
riffle.want(function (s) {...}, riffle.ModelObject(Student));
// Send a Student
var s = new Student();
s.first = "John";
s.last = "Smith";
s.grade = 90;
backend.call("send_student", s);
// Require a Student is returned
riffle.wait(function (s) {...}, riffle.ModelObject(Student));

// A model that contains a collection of models
function Student() {
    this.first = "firstName";
    this.last = "lastName";
    this.grade = 0;
}
function Classroom() {
    this.students = [Student];
    this.roomNumber = 0;
}
// Expect a Classroom
riffle.want(function (s) {...}, riffle.ModelObject(Classroom));
// Send a Classroom
var s = new Student();
s.first = "John";
s.last = "Smith";
s.grade = 90;
var c = new Classroom();
c.roomNumber = 100;
c.students[c.students.length] = s;
backend.call("send_classroom", c);
// Require a Classroom is returned
riffle.wait(function (c) {...}, riffle.ModelObject(Classroom));


// End Example Want Definitions Models
