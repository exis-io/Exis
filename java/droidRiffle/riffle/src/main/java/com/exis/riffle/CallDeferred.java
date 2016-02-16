package com.exis.riffle;

import com.exis.riffle.cumin.Cumin;
import com.exis.riffle.cumin.Handler;

/**
 * Created by damouse on 2/15/16.
 *
 * Like the regular deferred, but with many more options when it comes to handling arguments
 */
public class CallDeferred extends Deferred {


    @Override
    public Deferred then(Handler.Zero handler) {
        return _then (Cumin.cuminicate(handler));
    }

    // Start Generic Shotgun

public CallDeferred then(ZeroZero handler) {
    return _then (Cumin.cuminicate(handler));
}

public CallDeferred then(OneZero handler) {
    return _then (Cumin.cuminicate(handler));
}

public CallDeferred then(TwoZero handler) {
    return _then (Cumin.cuminicate(handler));
}

public CallDeferred then(ThreeZero handler) {
    return _then (Cumin.cuminicate(handler));
}

public CallDeferred then(FourZero handler) {
    return _then (Cumin.cuminicate(handler));
}

public CallDeferred then(FiveZero handler) {
    return _then (Cumin.cuminicate(handler));
}

public CallDeferred then(SixZero handler) {
    return _then (Cumin.cuminicate(handler));
}
