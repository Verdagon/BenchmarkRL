class LCGRand {
    var seed: UInt32
    init(seed: UInt32) { self.seed = seed }
    func next() -> UInt32 {
        let a: UInt32 = 1103515245
        let c: UInt32 = 12345
        let m: UInt32 = 0x7FFFFFFF
        let result = (a &* seed &+ c) % m
        seed = result
        return result
    }
}

let rand = LCGRand(seed: 1337)
for _ in 0..<10 {
    print(rand.next())
}
