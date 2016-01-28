# Example Want Definitions Models - all definitions for riffle.Models
# ARBITER set action defs
# In Python you must import:
import riffle
from riffle import want

# Declare a User class
class User(riffle.ModelObject):
    name = "default"
# define a function that is only called
# if a User is passed:
@want(User)
def myFunction(u):
    print(u.name) # User class
# call a function and expect the result to be
# a User class
u = example.call("get_user").wait(User)

# NOTE: each @want must decorate a function
# below, we removed them for clarity

# A basic model of a Student
class Student(riffle.ModelObject):
    first = "firstName"
    last = "lastName"
    grade = 0
@want(Student) # Decorate expecting a Student class
# Require a Student class is returned
s = example.call("get_student").wait(Student)

# A model that contains a collection of models
class Student(riffle.ModelObject):
    first = "firstName"
    last = "lastName"
    grade = 0
class Classroom(riffle.ModelObject):
    students = list(Student)
    roomNumber = 0
@want(Classroom) # Decorate expecting a Classroom class
# Require a Classroom class is returned
c = example.call("get_classroom").wait(Classroom)

# You could also define the object directly, but it
# wouldn't contain any functions defined in the class
class User(riffle.ModelObject):
    first = "firstName"
    def setFirst(self, name):
        self.first = name
# The result here enables u.setFirst('a')
@want(User) # Decorate to get a User
# Require a User so u.setFirst() can be called
u = example.call("get_user").wait(User)
# The result here won't have a u.setFirst() function
# because it is a dict not a User class
@want({"first": str})
u = example.call("get_user").wait({"first": str})

# End Example Want Definitions Models
