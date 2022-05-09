type ethAddressStr = string
type ethAddress

module Misc = {
  let unsafeToOption: (unit => 'a) => option<'a> = unsafeFunc => {
    try {
      unsafeFunc()->Some
    } catch {
    | Js.Exn.Error(_obj) => None
    }
  }
}

type ethersBigNumber
type txResult = {
  @dead("txResult.blockHash") blockHash: string,
  @dead("txResult.blockNumber") blockNumber: int,
  @dead("txResult.byzantium") byzantium: bool,
  @dead("txResult.confirmations") confirmations: int,
  // contractAddress: null,
  // cumulativeGasUsed: Object { _hex: "0x26063", … },
  // events: Array(4) [ {…}, {…}, {…}, … ],
  @dead("txResult.from") from: ethAddress,
  gasUsed: ethersBigNumber,
  // logs: Array(4) [ {…}, {…}, {…}, … ],
  // logsBloom: "0x00200000000000008000000000000000000020000001000000000000400020000000000000002000000000000000000000000002800010000000008000000000000000000000000000000008000000000040000000000000000000000000000000000000020000014000000000000800024000000000000000000010000000000000000000000000000000000000000000008000000000000000000000000200000008000000000000000000000000000000000800000000000000000000000000001002000000000000000000000000000000000000000020000000040020000000000000000080000000000000000000000000000000080000000000200000"
  @dead("txResult.status") status: int,
  @dead("txResult._to") _to: ethAddress,
  transactionHash: string,
  @dead("txResult.transactionIndex") transactionIndex: int,
}
type txHash = string
type txSubmitted = {
  hash: txHash,
  from: string,
  gasPrice: Js.Nullable.t<ethersBigNumber>,
  maxPriorityFeePerGas: Js.Nullable.t<ethersBigNumber>,
  maxFeePerGas: Js.Nullable.t<ethersBigNumber>,
  nonce: string,
  wait: (. unit) => Promise.t<txResult>,
}
type txError = {
  @dead("txError.code") code: int, // -32000 = always failing tx ;  4001 = Rejected by signer.
  message: string,
  @dead("txError.stack") stack: option<string>,
}

type abi

let makeAbi = (abiArray: array<string>): abi => abiArray->Obj.magic

module BigNumber = {
  type t = ethersBigNumber

  @module("ethers") @scope("BigNumber")
  external fromUnsafe: string => t = "from"
  @module("ethers") @scope("BigNumber")
  external fromInt: int => t = "from"

  @send external add: (t, t) => t = "add"
  @send external sub: (t, t) => t = "sub"
  @send external mul: (t, t) => t = "mul"
  @send external div: (t, t) => t = "div"
  @send external mod: (t, t) => t = "mod"
  @send external pow: (t, t) => t = "pow"
  @send external abs: t => t = "abs"

  @send external gt: (t, t) => bool = "gt"
  @send external gte: (t, t) => bool = "gte"
  @send external lt: (t, t) => bool = "lt"
  @send external lte: (t, t) => bool = "lte"
  @send external eq: (t, t) => bool = "eq"

  @send external toString: t => string = "toString"

  @send external toNumber: t => int = "toNumber"
  @send external toNumberFloat: t => float = "toNumber"

  let min = (a, b) => a->gt(b) ? b : a
  let max = (a, b) => a->gt(b) ? a : b
}

type providerType

module Provider = {
  type t = providerType

  module JsonRpcProvider = {
    @new @module("ethers") @scope("providers")
    external make: (string, ~chainId: int) => t = "JsonRpcProvider"
  }

  module FallbackProvider = {
    @new @module("ethers") @scope("providers")
    external make: (array<t>, ~quorum: int) => Promise.t<t> = "FallbackProvider"
  }

  type filter = {
    address: ethAddress,
    topics: array<string>,
  }

  @send external getBalance: (t, ethAddress) => Promise.t<option<BigNumber.t>> = "getBalance"
  @send
  external getBlockNumber: t => Promise.t<int> = "getBlockNumber"

  @send
  external lookupAddress: (t, ethAddress) => Promise.t<option<string>> = "lookupAddress"

  @send
  external on: (t, string, 'a) => unit = "on"
  @send
  external removeAllListeners: (t, string) => unit = "removeAllListeners"

  @send
  external waitForTransaction: (providerType, txHash) => Promise.t<txResult> = "waitForTransaction"

  type feeData = {
    gasPrice: ethersBigNumber,
    maxFeePerGas: ethersBigNumber,
    maxPriorityFeePerGas: ethersBigNumber,
  }
  @send
  external getFeeData: providerType => Promise.t<feeData> = "getFeeData"
}

type walletType = {@as("_address") address: string, provider: providerType}

module Wallet = {
  type t = walletType

  @new @module("ethers") @scope("Wallet")
  external makePrivKeyWallet: (string, providerType) => t = "Wallet"

  @new @module("ethers") @scope("Wallet")
  external fromMnemonic: string => t = "fromMnemonic"

  @new @module("ethers") @scope("Wallet")
  external fromMnemonicWithPath: (~mnemonic: string, ~path: string) => t = "fromMnemonic"

  type rawSignature
  @send
  external signMessage: (t, string) => Promise.t<rawSignature> = "signMessage"

  @send external connect: (t, Provider.t) => t = "connect"

  @send external getBalance: t => Promise.t<BigNumber.t> = "getBalance"

  @send external getTransactionCount: t => Promise.t<BigNumber.t> = "getTransactionCount"
}

type providerOrWallet =
  | ProviderWrap(Provider.t)
  | WalletWrap(Wallet.t)

let wrapProvider: providerType => providerOrWallet = p => ProviderWrap(p)

let wrapWallet: walletType => providerOrWallet = w => WalletWrap(w)

module Contract = {
  type t

  type txOptions = {
    @live gasLimit: option<string>,
    @live value: BigNumber.t,
  }

  type tx = {
    hash: txHash,
    wait: (. unit) => Promise.t<txResult>,
  }

  @new @module("ethers")
  external getContractSigner: (ethAddress, abi, Wallet.t) => t = "Contract"
  @new @module("ethers")
  external getContractProvider: (ethAddress, abi, Provider.t) => t = "Contract"

  let make: (ethAddress, abi, providerOrWallet) => t = (address, abi, providerSigner) => {
    switch providerSigner {
    | ProviderWrap(provider) => getContractProvider(address, abi, provider)
    | WalletWrap(signer) => getContractSigner(address, abi, signer)
    }
  }
}

module Utils = {
  type ethUnit = [
    | #wei
    | #kwei
    | #mwei
    | #gwei
    | #microether
    | #milliether
    | #ether
    | #kether
    | #mether
    | #geher
    | #tether
  ]
  @module("ethers") @scope("utils")
  external parseUnitsUnsafe: (. string, ethUnit) => BigNumber.t = "parseUnits"
  let parseUnits = (~amount, ~unit) => Misc.unsafeToOption(() => parseUnitsUnsafe(. amount, unit))

  let parseEther = (~amount) => parseUnits(~amount, ~unit=#ether)
  let parseEtherUnsafe = (~amount) => parseUnitsUnsafe(. amount, #ether)

  @module("ethers") @scope("utils")
  external getAddressUnsafe: string => ethAddress = "getAddress"

  let getAddress: string => option<ethAddress> = addressString =>
    Misc.unsafeToOption(() => getAddressUnsafe(addressString))

  @module("ethers") @scope("utils")
  external formatUnits: (. BigNumber.t, ethUnit) => string = "formatUnits"

  let formatEther = formatUnits(. _, #ether)

  let tenBN = BigNumber.fromInt(10)

  let make18DecimalsNormalizer = (~decimals) => {
    open BigNumber

    let multiplierOrDivisor = tenBN->pow(Js.Math.abs_int(18 - decimals)->fromInt)
    switch decimals {
    | d if d < 18 => num => num->mul(multiplierOrDivisor)
    | d if d > 18 => num => num->div(multiplierOrDivisor)
    | _ => num => num
    }
  }

  let normalizeTo18Decimals = (num, ~decimals) => {
    make18DecimalsNormalizer(~decimals)(num)
  }

  let formatEtherToPrecision = (number, digits) => {
    let digitMultiplier = Js.Math.pow_float(~base=10.0, ~exp=digits->Belt.Float.fromInt)
    number
    ->formatEther
    ->Belt.Float.fromString
    ->Belt.Option.getExn
    ->(x => x *. digitMultiplier)
    ->Js.Math.floor_float
    ->(x => x /. digitMultiplier)
    ->Belt.Float.toString
  }

  let ethAdrToStr: ethAddress => string = Obj.magic
  let ethAdrToLowerStr: ethAddress => string = address =>
    address->ethAdrToStr->Js.String.toLowerCase
}
