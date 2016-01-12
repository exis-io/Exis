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
        @want(str)
        def myFirstSub(s):
            print(s)  # Expects a str, like "Hello"
        self.subscribe("myFirstSub", myFirstSub)
        # End Example Tour Pub/Sub Lesson 1
        
        ######################################################################################
        # xample Tour Reg/Call Lesson 2 Works - type enforcement good
        @want(str)
        def iWantStrings(s):
            print(s)  # Expects a str, like "Hi"
            return "Thanks for saying {}".format(s)
        self.register("iWantStrings", iWantStrings)
        # nd Example Tour Reg/Call Lesson 2 Works
        
        # xample Tour Reg/Call Lesson 2 Fails - type enforcement bad
        @want(int)
        def iWantInts(i):
            print(i)  # Expects an int, like 42
            return "Thanks for sending int {}".format(i)
        self.register("iWantInts", iWantInts)
        # nd Example Tour Reg/Call Lesson 2 Fails
    
        # xample Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
        @want(str)
        def iGiveInts(s):
            print(s)  # Expects a str, like "Hi"
            return 42
        self.register("iGiveInts", iGiveInts)
        # nd Example Tour Reg/Call Lesson 2 Wait Check
        
        ######################################################################################
        # xample Tour Reg/Call Lesson 3 Works - collections of types
        @want([str])
        def iWantManyStrings(s):
            print(s)  # Expects a [str], like ["This", "is", "cool"]
            return "Thanks for {} strings!".format(len(s))
        self.register("iWantManyStrings", iWantManyStrings)
        # nd Example Tour Reg/Call Lesson 3 Works
        
        # xample Tour Reg/Call Lesson 3 Fails - collections of types
        @want([int])
        def iWantManyInts(i):
            print(i)  # Expects a [int], like [0, 1, 2]
            return "Thanks for {} ints!".format(len(i))
        self.register("iWantManyInts", iWantManyInts)
        # nd Example Tour Reg/Call Lesson 3 Fails
        
        ######################################################################################
        # xample Tour Reg/Call Lesson 4 Basic Student - intro to classes
        class Student(riffle.Model):
            name = "Student Name"
            age = 20
            studentID = 0
            def __str__(self):
                return "{}, Age: {}, ID: {}".format(self.name, self.age, self.studentID)
        @want(Student)
        def sendStudent(s):
            print s # Expects a Student, like "John Smith, Age: 18, ID: 1234"
        self.register("sendStudent", sendStudent)
        # nd Example Tour Reg/Call Lesson 4 Basic Student
        
        # xample Tour Reg/Call Lesson 4 Student Functions - intro to class functions
        class Student(riffle.Model):
            name, age, studentID = "Student Name", 20, 0
            def changeID(self, newID):
                self.studentID = 5678
        @want(Student)
        def changeStudentID(s):
            print s.studentID # Expects an int, like 1234
            s.changeID(5678)
            return s
        self.register("changeStudentID", changeStudentID)
        # nd Example Tour Reg/Call Lesson 4 Student Functions
        
        print "___SETUPCOMPLETE___"
        

# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup
