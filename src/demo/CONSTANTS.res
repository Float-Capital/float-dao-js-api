let {fromUnsafe, fromInt} = module(Ethers.BigNumber)

let oneGweiInWei = fromInt(1000000000)

let zeroBN = fromInt(0)
let fourBN = fromInt(4)
let tenToThe4 = fromInt(10000)
let tenToThe9 = oneGweiInWei
let tenToThe15 = fromUnsafe("1000000000000000")
let tenToThe18 = fromUnsafe("1000000000000000000")
