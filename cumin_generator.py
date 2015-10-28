'''
Generator for Cumin functions. 

TODO:
    Get rid of empty angle brackets
    
'''

import os

PRODUCTION = 'Pod/Classes/GenericWrappers.swift'
DEV = 'cumin.txt'

generics = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
returns = ['R', 'S', 'T', 'U', 'V', 'X', 'Y', 'Z']

outputTemplate = "// Straight Boilerplate-- make the compiler happy\nimport Foundation\n\npublic extension RiffleSession {\n"

callerTemplate = '\tpublic func %s<%s>(pdid: String, _ fn: (%s) -> (%s))  {\n\t\t_%s(pdid, fn: cumin(fn))\n\t}'
callTemplate = '\tpublic func %s<%s>(pdid: String, _ args: AnyObject..., handler fn: ((%s) -> (%s))?)  {\n\t\t_%s(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))\n\t}'
cuminTemplate = 'public func cumin<%s>(fn: (%s) -> (%s)) -> ([AnyObject]) -> (%s) {\n\treturn { (a: [AnyObject]) in fn(%s) }\n}'


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

def renderSet(template, name, args, ret, cuminSpecific):
    result = []
    finalArgs = ', '.join(args)
    finalReturns = ', '.join(ret)

    lastReplace = ', '.join(["%s.self <- a[%s]" % (x, i) for i, x in enumerate(args)]) if cuminSpecific else name

    for generics, wheres in binaryMask(args + ret, "%s: CN", "%s: CL", "%s.Generator.Element : CN"):
        finalGenerics = ', '.join(generics)
        finalWheres = ', '. join(wheres)
        finalBoth = finalGenerics +  ' where ' + finalWheres if finalWheres is not '' else finalGenerics         

        templated = (template % (name, finalBoth, finalArgs, finalReturns, lastReplace,)).replace("<>", "")
        result.append(templated)

    return result

def main():
    c, r, s, n = [], [], [], []
    out = DEV

    # Generate cumins
    for j in range(2):
        for i in range(0, 2):
            if j == 0:
                s += renderSet(callerTemplate, 'subscribe', generics[:i], returns[:j], False)
                n += renderSet(callTemplate, 'call', generics[:i], returns[:j], False)

            r += renderSet(callerTemplate, 'register', generics[:i], returns[:j], False)
            c += renderSet(cuminTemplate, 'cumin', generics[:i], returns[:j], True)

    e = r + s + n + c
    with open(os.path.join(os.getcwd(), out), 'w') as f:
        f.write(outputTemplate)
        e = r + s + n 

        [f.write(x + '\n\n') for x in e]
        f.write("}\n\n")

        [f.write(x + '\n\n') for x in c]

# Apply some different formatting to the passed list of characters
def binaryMask(source, normalFmt, maskedFmt, tailfmt):
    ret = []

    for i in range(2 ** len(source)):
        generics, tail = [], []

        for x, y in zip(list(('{0:0%sb}' % len(source)).format(i)), source):
            if x is '0':
                generics.append(normalFmt % y)
            else: 
                generics.append(maskedFmt % y)
                tail.append(tailfmt % y)

        ret.append((generics, tail))

    return ret

if __name__ == '__main__':
    main()

    # print binaryMask(generics[:3], "%s: CN", "%s: CL", "%s.Generator.Element : CN")
    # print binaryMask(generics[:3], "[%s]", "%s: stuff")

