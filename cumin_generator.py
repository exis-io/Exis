'''
Generator for Cumin functions. 
'''

import os

generics = ['A', 'B', 'C', 'D', 'E', 'F']
returns = ['R', 'S']

def renderCumin(args, ret):
    p = ', '.join(["args[%s] as! %s" % (i, x) for i, x in enumerate(args)])
    both = ', '.join(args + ret)
    args = ', '.join(args)
    ret = ', '.join(ret)

    return 'func cumin<%s>(fn: (%s) -> (%s)) -> ([AnyObject]) -> (%s) {\n\treturn { (args: \
[AnyObject]) in fn(%s) }\n}' % (both, args, ret, ret, p)

def renderCaller(name, args, ret):
    args = ', '.join(args)
    ret = ', '.join(ret)

    return 'public func %s<%s>(pdid: String, _ fn: (%s) -> (%s))  {\n\t_%s(\
pdid, fn: cumin(fn))\n}' % (name, args, args, ret, name,)

def main():
    c, r, s = [], [], []

    # Generate cumins
    for j in range(2):
        for i in range(0, 4):
            if j == 0:
                s.append(renderCaller('subscribe', generics[:i], returns[:j]))

            r.append(renderCaller('register', generics[:i], returns[:j]))
            c.append(renderCumin(generics[:i], returns[:j]))

    e = r + s + c
    with open(os.path.join(os.getcwd(), 'cumin.txt'), 'w') as f:
        [f.write(x + '\n\n') for x in e]

if __name__ == '__main__':
    

    main()
    # print renderCumin(generics[:2], returns[:1])

