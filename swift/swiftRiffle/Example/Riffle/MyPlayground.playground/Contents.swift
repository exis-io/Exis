import Foundation

let ID_UPPER_BOUND = UInt64(pow(Double(2), Double(53)))

func random64() -> UInt64 {
    var rnd : UInt64 = 0
    arc4random_buf(&rnd, sizeofValue(rnd))
    return rnd % ID_UPPER_BOUND
}

random64()
random64()
random64()
random64()