# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        
        ######################################################################################
        # Example Tour Pub/Sub Lesson 1 - our first basic example
        backend.publish("myFirstSub", "Hello")
        # End Example Tour Pub/Sub Lesson 1

        ######################################################################################
        # xample Tour Reg/Call Lesson 2 Works - type enforcement good
        s = backend.call("iWantStrings", "Hi").wait(str)
        print s # Expects a str, like "Thanks for saying Hi"
        # nd Example Tour Reg/Call Lesson 2 Works
        
        # xample Tour Reg/Call Lesson 2 Fails - type enforcement bad
        try:
            s = backend.call("iWantInts", "Hi").wait(str)
            print s # Expects a str, like "Thanks for sending int 42"
        except riffle.Error as e:
            print e # Errors with "Cumin: expecting primitive int, got string"
        # nd Example Tour Reg/Call Lesson 2 Fails
        
        # xample Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
        try:
            s = backend.call("iGiveInts", "Hi").wait(str)
            print s # Expects a str, like "Hello"
        except riffle.Error as e:
            print e # Errors with "Cumin: expecting primitive int, got string"
        # nd Example Tour Reg/Call Lesson 2 Wait Check
        
        ######################################################################################
        # xample Tour Reg/Call Lesson 3 Works - collections of types
        s = backend.call("iWantManyStrings", ["This", "is", "cool"]).wait(str)
        print s # Expects a str, like "Thanks for 3 strings!"
        # nd Example Tour Reg/Call Lesson 3 Works
        
        # xample Tour Reg/Call Lesson 3 Fails - collections of types
        try:
            s = backend.call("iWantManyInts", [0, 1, "two"]).wait(str)
            print s # Expects a str, like "Thanks for 3 ints!"
        except riffle.Error as e:
            print e # Errors with "Cumin: expecting primitive int, got string"
        # nd Example Tour Reg/Call Lesson 3 Fails
        
        ######################################################################################
        # xample Tour Reg/Call Lesson 4 Basic Student - intro to classes
        class Student(riffle.Model):
            name = "Student Name"
            age = 20
            studentID = 0
        s = Student()
        s.name = "John Smith"
        s.age = 18
        s.studentID = 1234
        backend.call("sendStudent", s).wait()
        # nd Example Tour Reg/Call Lesson 4 Basic Student
        
        # xample Tour Reg/Call Lesson 4 Student Functions - intro to class functions
        class Student(riffle.Model):
            name, age, studentID = "Student Name", 20, 0
        s = Student()
        s.name, s.age, s.studentID = "John Smith", 18, 1234
        s = backend.call("changeStudentID", s).wait(Student)
        print s.studentID # Expects an int, like 5678
        # nd Example Tour Reg/Call Lesson 4 Student Functions

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup
