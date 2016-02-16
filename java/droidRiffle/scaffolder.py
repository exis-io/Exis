
import os
from string import Template

outputPath = os.path.join(os.getcwd(), 'riffle/src/main/java/com/exis/riffle/')

# OI-- does this need generic information too?
#    public Deferred then(Handler.Zero handler) {
#        return _then (Cumin.cuminicate(handler));
#    }

callDeferredTemplate = '''
public $genericList CallDeferred then($genericClassList $handlerType handler) {
    return _then (Cumin.cuminicate($classVars handler));
}
'''

#    public static <A> Wrapped cuminicate(Class<A> a, Handler.One<A> fn) {
#        return (q) -> { fn.run(convert(a, q[0])); return null; };
#    }

cuminTemplate = '''
public static $genericList Wrapped cuminicate($genericClassList, $handler fn) {
    return (q) -> { fn.run($converters); return null; };
}
'''

#    public <A> Deferred register(String endpoint, Class<A> a, Handler.One<A> handler) {
#        return _register(endpoint, Cumin.cuminicate(a, handler));
#    }

handlerTemplate = '''
public $genericList Deferred $name(String endpoint, $genericClassList $handler handler) {
    return _$name(endpoint, Cumin.cuminicate($cuminicateArgs));
}
'''

#   interface Two<A, B> { void run(A a, B b); }
#   interface Three<A, B, C> { void run(A a, B b, C c); }
interfaceTemplate = '''
    interface $name$genericList { $ret run($paramList); }
'''

allGenerics = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
returns = ['R']
handlerNames = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven']


def generateBasics(i, j):
    genericList = allGenerics[:i] + returns[:j]
    classList = ', '.join(["Class<%s> %s" % (x, x.lower()) for x in genericList])

    generics = "" if len(genericList) == 0 else "<%s>" % ', '.join(genericList)

    handler = "Handler.%s%s" % (handlerNames[i] + handlerNames[j], generics)

    return generics, genericList, classList, handler


def renderDeferred(i, j):
    generics, genericList, classList, handler = generateBasics(i, j)
    classList = classList + ', ' if len(classList) > 0 else classList
    handler = "Handler.%s%s" % (handlerNames[i] + handlerNames[j], generics)
    
    classVars = ', '.join([x.lower() for x in genericList])
    classVars = classVars + ', ' if len(classVars) > 0 else classVars

    classes = ', '.join(["convert(%s, q[%s])" % (x.lower(), i) for i, x in enumerate(genericList)])


    return Template(callDeferredTemplate).substitute(genericList=generics, handlerType=handler, genericClassList=classList, classVars=classVars)


def renderCumin(i, j):
    generics, genericList, classList, handler = generateBasics(i, j)
    converters = ', '.join(["convert(%s, q[%s])" % (x.lower(), i) for i, x in enumerate(genericList)])

    return Template(cuminTemplate).substitute(genericList=generics, genericClassList=classList, handler=handler, converters=converters)


def renderHandler(i, j, name):
    generics, genericList, classList, handler = generateBasics(i, j)
    
    cuminicateArgs = [x.lower() for x in genericList]
    cuminicateArgs.append('handler')
    cuminicateArgs = ", ".join(cuminicateArgs)

    classList = classList + ', ' if len(classList) > 0 else classList

    return Template(handlerTemplate).substitute(genericList=generics, name=name, genericClassList=classList, handler=handler, cuminicateArgs=cuminicateArgs)


def renderInterface(i, j):
    generics, genericList, classList, handler = generateBasics(i, j)
    paramList = ", ".join("%s %s" % (x, x.lower()) for x in genericList)
    ret = "void" if j == 0 else "R"
    return Template(interfaceTemplate).substitute(genericList=generics, name=(handlerNames[i] + handlerNames[j]), paramList=paramList, ret=ret)

# Replaces the exising lines with these new lines


def foldLines(f, addition):
    start_marker = '// Start Generic Shotgun'
    end_marker = '// End Generic Shotgun'
    ret = []

    with open(f) as inf:
        ignoreLines = False
        written = False

        for line in inf:
            if end_marker in line:
                ignoreLines = False

            if ignoreLines:
                if not written:
                    written = True
                    [ret.append(x) for x in addition]
            else:
                ret.append(line)

            if start_marker in line:
                ignoreLines = True

    return ret

def foldAndWrite(fileName, lines):
    fileName = os.path.join(outputPath, fileName)
    lines = foldLines(fileName, lines)

    with open(fileName, 'w') as f:
        [f.write(x) for x in lines]

if __name__ == '__main__':
    call, cumin, subs, reg, interfaces = [], [], [], [], []

    for j in range(2):  # The number of return types
        for i in range(0, 7):  # Number of parameters
            if j == 0:
                call.append(renderDeferred(i, j))
                subs.append(renderHandler(i, j, 'subscribe'))

            reg.append(renderHandler(i, j, 'register'))
            cumin.append(renderCumin(i, j))
            interfaces.append(renderInterface(i, j))
    
    foldAndWrite('cumin/Cumin.java', cumin)
    foldAndWrite('CallDeferred.java', call)
    foldAndWrite('Domain.java', subs + reg)
    foldAndWrite('cumin/Handler.java', interfaces)
