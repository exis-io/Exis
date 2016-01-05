'''
Generator for Cumin functions. 
'''

import os

PRODUCTION = 'Pod/Classes/GenericWrappers.swift'
DEV = 'cumin.txt'

generics = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
returns = ['R', 'S', 'T', 'U', 'V', 'X', 'Y', 'Z']

handlerTemplate = '\tpublic func %s<%s>(endpoint: String, _ fn: (%s) -> (%s)) -> Deferred {\n\t\treturn _%s(pdid, fn: cumin(fn))\n\t}'
callTemplate = '\tpublic func %s<%s>(endpoint: String, _ args: AnyObject..., handler fn: ((%s) -> (%s))?) -> Deferred {\n\t\treturn _%s(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))\n\t}'


def renderCaller(template, name, args, ret, renderingArrays):
    both = ', '.join([x + ": PR" for x in args] + ret)
    args = ', '.join(args)
    ret = ', '.join(ret)

    return (template % (name, both, args, ret, name,)).replace("<>", "")


def main():
    r, s, n = [], [], []

    for j in range(2):  # The number of return types
        for i in range(0, 7):  # Number of parameters
            if j == 0:
                s.append(renderCaller(handlerTemplate, 'subscribe', generics[:i], returns[:j], False))
                n.append(renderCaller(callTemplate, 'call', generics[:i], returns[:j], False))

            r.append(renderCaller(handlerTemplate, 'register', generics[:i], returns[:j], False))

    with open(os.path.join(os.getcwd(), DEV), 'w') as f:
        f.write("import Foundation\n\npublic extension Domain {\n")
        e = r + s + n

        [f.write(x + '\n\n') for x in e]
        f.write("}\n\n")

if __name__ == '__main__':
    main()
