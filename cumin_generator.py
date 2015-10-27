'''
Generator for Cumin functions. 

TODO:
    Get rid of empty angle brackets
    
'''

import os

generics = ['A', 'B', 'C', 'D', 'E', 'F']
returns = ['R', 'S', 'T', 'U', 'V']

callerTemplate = 'public func %s<%s>(pdid: String, _ fn: (%s) -> (%s))  {\n\t_%s(pdid, fn: cumin(fn))\n}'
callTemplate = 'public func %s<%s>(pdid: String, _ args: AnyObject..., handler fn: ((%s) -> (%s))?)  {\n\t_%s(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))\n}'
outputTemplate = "// Straight Boilerplate-- make the compiler happy\nimport Foundation\n\npublic extension RiffleSession {\n"

def convertible(args):
    # Adds the convertible tag to all the given generic arguments
    return [x + ": CN" for x in args]

def renderCumin(args, ret):
    p = ', '.join(["%s.self <- a[%s]" % (x, i) for i, x in enumerate(args)])
    both = ', '.join(convertible(args + ret))
    args = ', '.join(args)
    ret = ', '.join(ret)

    return ('public func cumin<%s>(fn: (%s) -> (%s)) -> ([AnyObject]) -> (%s) {\n\treturn { (a: \
[AnyObject]) in fn(%s) }\n}' % (both, args, ret, ret, p)).replace("<>", "")

def renderCaller(template, name, args, ret):
    both = ', '.join(convertible(args + ret))
    args = ', '.join(args)
    ret = ', '.join(ret)

    return (template % (name, both, args, ret, name,)).replace("<>", "")

def main():
    c, r, s, n = [], [], [], []

    # Generate cumins
    for j in range(4):
        for i in range(0, 6):
            if j == 0:
                s.append(renderCaller(callerTemplate, 'subscribe', generics[:i], returns[:j]))
                n.append(renderCaller(callTemplate, 'call', generics[:i], returns[:j]))

            r.append(renderCaller(callerTemplate, 'register', generics[:i], returns[:j]))
            c.append(renderCumin(generics[:i], returns[:j]))

    e = r + s + n + c
    with open(os.path.join(os.getcwd(), 'Pod/Classes/GenericWrappers.swift'), 'w') as f:
        f.write(outputTemplate)
        e = r + s + n 
        [f.write('\t' + x + '\n\n') for x in e]
        f.write("}\n\n")

        [f.write(x + '\n\n') for x in c]

if __name__ == '__main__':
    main()


