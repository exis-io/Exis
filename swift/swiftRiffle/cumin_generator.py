'''
Generator for Cumin functions. 
'''

import os

# Header for the cumin file
header = '''
// 
// Cumin generic wrapper functions. Each overloaded function corresponds to a handler with a different number of 
// arguments and return types
//
// Generated by cuminGenerator.py
// 

import Foundation

// Converter operator. Attempts to convert the object on the right to the type given on the left
// Just here to make the cumin conversion functions just the smallest bit clearer
infix operator <- {
associativity right
precedence 155
}

func <- <T: Property> (t:T.Type, object: Any) -> T {
    // Deserialize is implemented as part of the Convertible protocol. All properties implement Convertible
    
    #if os(OSX)
        return T.brutalize(object, t: T.self)!
    #else
        return T.deserialize(object) as! T
    #endif
}

// Used only in this file to shorten the length of the method signatures
public typealias PR = Property

public extension Domain {

'''

deferredHeader = '''

// Deferred handler overloads
public extension HandlerDeferred {

'''

PRODUCTION = 'Pod/Classes/Cumin.swift'
DEV = 'cumin.txt'

generics = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
returns = ['R', 'S', 'T', 'U', 'V', 'X', 'Y', 'Z']

handlerTemplate = '\tpublic func %s<%s>(endpoint: String, _ fn: (%s) -> (%s)) -> Deferred {\n\t\treturn _%s(endpoint, [%s]) { a in return %s }\n\t}'
callTemplate = '\tpublic func %s<%s>(fn: (%s) -> (%s)) -> Deferred {\n\t\treturn _%s([%s]) { a in return %s }\n\t}'


def renderCaller(template, name, args, ret, renderingArrays, serializeResults=False):
    cumin = ', '.join(["%s.self <- a[%s]" % (x, i) for i, x in enumerate(args)])
    types = ', '.join([x + ".representation()" for x in args])
    both = ', '.join([x + ": PR" for x in args] + [x + ": PR" for x in ret])
    args = ', '.join(args)
    ret = ', '.join(ret)
    invokcation = "fn(%s)" % cumin

    if serializeResults:
        invokcation = "serializeResults(%s)" % invokcation

    return (template % (name, both, args, ret, name, types, invokcation)).replace("<>", "")


def main():
    r, s, c = [], [], []

    for j in range(6):  # The number of return types
        for i in range(0, 7):  # Number of parameters
            if j == 0:
                s.append(renderCaller(handlerTemplate, 'subscribe', generics[:i], returns[:j], False))

                if i > 0:
                    c.append(renderCaller(callTemplate, 'then', generics[:i], returns[:j], False))

            r.append(renderCaller(handlerTemplate, 'register', generics[:i], returns[:j], False, serializeResults=True))

    with open(os.path.join(os.getcwd(), PRODUCTION), 'w') as f:
        f.write(header)
        [f.write(x + '\n\n') for x in (r + s)]
        f.write("}\n")

        f.write(deferredHeader)
        [f.write(x + '\n\n') for x in c]
        f.write("}\n\n")

if __name__ == '__main__':
    main()
