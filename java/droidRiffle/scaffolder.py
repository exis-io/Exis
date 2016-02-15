
import os
from string import Template

# OI-- does this need generic information too?
#    public Deferred then(Handler.Zero handler) {
#        return _then (Cumin.cuminicate(handler));
#    }

callDeferredTemplate = '''
public Deferred then($handlerType handler) {
    return _then (Cumin.cuminicate(handler));
}

'''

#    public static <A> Wrapped cuminicate(Class<A> a, Handler.One<A> fn) {
#        return (q) -> { fn.run(convert(a, q[0])); return null; };
#    }

cuminTemplate = '''
public static <A> Wrapped cuminicate(Class<A> a, Handler.One<A> fn) {
    return (q) -> { fn.run(convert(a, q[0])); return null; };
}

'''

#    public <A> Deferred register(String endpoint, Class<A> a, Handler.One<A> handler) {
#        return _register(endpoint, Cumin.cuminicate(a, handler));
#    }

handlerTemplate = '''
public <$genericList> Deferred $name(String endpoint, $genericClassList, $handler) {
    return _$name(endpoint, Cumin.cuminicate(a, handler));
}
'''

generics = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
returns = ['R']
handlerNames = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven']


def renderDeferred(params, returns):
    return Template(callDeferredTemplate).substitute(handlerType=(handlerNames[i] + handlerNames[j]))


def renderCumin(params, returns, name):
    genericList = generics[:params] + returns[:returns]
    classList = ', '.join(["Class<%s> %s" % (x, x.lower()) for x in genericList])
    handler = "Handler.%s<%s>" % (handlerNames[i] + handlerNames[j], ', '.join(genericList))

    return Template(cuminTemplate).substitute(genericList=", ".join(genericList), name=name, genericClassList=classList, handler=handler)


def renderHandler():
    pass

if __name__ == '__main__':
    # terms = dict(title="Doctor", name="Mickey", job='Boss')
    # print Template(template).substitute(terms)

    call, cumin, handler = [], [], []

    for j in range(2):  # The number of return types
        for i in range(0, 7):  # Number of parameters
            if j == 0:
                call.append(renderDeferred(i, j))

                if i > 0:
                    # c.append(renderCaller(callTemplate, 'then', generics[:i], returns[:j], False))
                    pass

            call.append(renderCumin(i, j, 'register'))
            call.append(renderCumin(i, j, 'subscribe'))
            pass

    with open(os.path.join(os.getcwd(), 'cumin.txt'), 'w') as f:
        [f.write(x + '\n\n') for x in (call + cumin + handler)]
