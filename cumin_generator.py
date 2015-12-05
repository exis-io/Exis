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

outputTemplate = "// Straight Boilerplate-- make the compiler happy\nimport Foundation\n\npublic extension RiffleDomain {\n"

callerTemplate = '\tpublic func %s<%s>(pdid: String, _ fn: (%s) -> (%s)) -> Deferred {\n\t\treturn _%s(pdid, fn: cumin(fn))\n\t}'
callTemplate = '\tpublic func %s<%s>(pdid: String, _ args: AnyObject..., handler fn: ((%s) -> (%s))?) -> Deferred {\n\t\treturn _%s(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))\n\t}'

# The firstis used for modeling collections of cuminicable items. Second is for arbitrary cuminicables
cuminCollectionTemplate = 'public func cumin<%s>(fn: (%s) -> (%s)) -> ([AnyObject]) throws -> (%s) {\n\treturn { (a: [AnyObject]) in fn(%s) }\n}'
cuminTemplate = 'public func cumin<%s>(fn: (%s) -> (%s)) -> ([AnyObject]) throws -> (%s) {\n\treturn { (a: [AnyObject]) in fn(%s) }\n}'


def renderGenericList(args, ret, array):
    # To genericate the return types, remove the "ret" call
    if array:
        collectionGenerics = ', '.join(map(lambda x: "%s: CL" % x, args) + ret)
        wherables = ', '.join(map(lambda x: "%s.Generator.Element : CN" % x, args))
        return collectionGenerics +  ' where ' + wherables if wherables is not '' else collectionGenerics      
    else:
        return ', '.join([x + ": CN" for x in args] + ret)

def renderCumin(args, ret, renderingArrays):
    p = ', '.join(["try %s.self <- a[%s]" % (x, i) for i, x in enumerate(args)])
    both = renderGenericList(args, ret, renderingArrays)

    finalArgs = ', '.join(args)
    ret = ', '.join(ret)

    return (cuminCollectionTemplate % (both, finalArgs, ret, ret, p)).replace("<>", "")

def renderCaller(template, name, args, ret, renderingArrays):
    both = renderGenericList(args, ret, renderingArrays)    
    args = ', '.join(args)
    ret = ', '.join(ret)

    return (template % (name, both, args, ret, name,)).replace("<>", "")

def renderSet(template, name, args, ret, cuminSpecific):
    result = []
    finalArgs = ', '.join(args)
    finalReturns = ', '.join(ret)

    lastReplace = ', '.join(["try %s.self <- a[%s]" % (x, i) for i, x in enumerate(args)]) if cuminSpecific else name

    for generics, wheres in binaryMask(args + ret, "%s: CN", "%s: CL", "%s.Generator.Element : CN"):
        finalGenerics = ', '.join(generics)
        finalWheres = ', '. join(wheres)
        finalBoth = finalGenerics +  ' where ' + finalWheres if finalWheres is not '' else finalGenerics         

        if cuminSpecific:
            templated = template % (finalBoth, finalArgs, finalReturns, finalReturns, lastReplace,)
        else:
            templated = template % (name, finalBoth, finalArgs, finalReturns, lastReplace,)

        result.append(templated.replace("<>", ""))

    return result

def main():
    c, r, s, n = [], [], [], []
    out = PRODUCTION

    # The big renderSets are waaay too big-- it actually freezes xcode when attempting to compile. 
    # For now, just allow ONLY array returns and regular old returns

    # Generate cumins
    for j in range(2):
        for i in range(0, 7):
            if j == 0:

                # We have to limit the array ones, since they get out of hand quickly
                if i < 5:
                    s += renderSet(callerTemplate, 'subscribe', generics[:i], returns[:j], False)
                    n += renderSet(callTemplate, 'call', generics[:i], returns[:j], False)
                else:
                    s.append(renderCaller(callerTemplate, 'subscribe', generics[:i], returns[:j], False))
                    s.append(renderCaller(callerTemplate, 'subscribe', generics[:i], returns[:j], True))

            #     n.append(renderCaller(callTemplate, 'call', generics[:i], returns[:j], False))
            #     n.append(renderCaller(callTemplate, 'call', generics[:i], returns[:j], True))

            # r.append(renderCaller(callerTemplate, 'register', generics[:i], returns[:j], False))
            # r.append(renderCaller(callerTemplate, 'register', generics[:i], returns[:j], True))

            # c.append(renderCumin(generics[:i], returns[:j], False))
            # c.append(renderCumin(generics[:i], returns[:j], True))

            if j == 0 and i < 5:
                r += renderSet(callerTemplate, 'register', generics[:i], returns[:j], False)
                c += renderSet(cuminTemplate, 'cumin', generics[:i], returns[:j], True)
            else:
                r.append(renderCaller(callerTemplate, 'register', generics[:i], returns[:j], False))
                # r.append(renderCaller(callerTemplate, 'register', generics[:i], returns[:j], True))

                c.append(renderCumin(generics[:i], returns[:j], False))
                c.append(renderCumin(generics[:i], returns[:j], True))

    with open(os.path.join(os.getcwd(), out), 'w') as f:
        f.write(outputTemplate)
        e = seperateLists(r) + seperateLists(s) + seperateLists(n) 

        [f.write(x + '\n\n') for x in e]
        f.write("}\n\n")

        [f.write(x + '\n\n') for x in seperateLists(c)]

# Splits off the listy lines from the unlisty ones
def seperateLists(prints):
    withoutLists, withLists = [], []

    for x in prints:
        withoutLists.append(x) if 'Generator' in x else withLists.append(x)

    return withLists + withoutLists

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

