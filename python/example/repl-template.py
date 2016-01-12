# Example REPL Template - The REPL code
# ARBITER set action template
import riffle
from riffle import want

riffle.SetFabricSandbox()

class Backend(riffle.Domain):

    def onJoin(self):
        
        # Exis code goes here
        

app = riffle.Domain("xs.demo.test")

Backend("backend", superdomain=app).join()
# End Example REPL Template
