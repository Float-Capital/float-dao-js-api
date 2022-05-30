open Float__Ethers

@val external process: 'a = "process"
let env = process["env"]

@module("../secretsManager.js") external mnemonic: string = "mnemonic"
@module("../secretsManager.js") external providerUrlOther: string = "providerUrl"

let {oneGweiInWei, fromInt} = module(Float__Ethers.BigNumber)

let connectToNewWallet = (provider, ~mnemonic) =>
  Wallet.fromMnemonicWithPath(~mnemonic, ~path=`m/44'/60'/0'/0/0`)->Wallet.connect(provider)

let providerUrl = FloatConfig.avalancheConfig.rpcEndpoint
let chainId = FloatConfig.avalancheConfig.networkId

let provider = providerUrl->Provider.JsonRpcProvider.make(~chainId)
let wallet = providerUrl->Provider.JsonRpcProvider.make(~chainId)->connectToNewWallet(~mnemonic)

let maxFeePerGas = BigNumber.fromInt(62)->BigNumber.mul(oneGweiInWei)
let maxPriorityFeePerGas = BigNumber.fromInt(34)->BigNumber.mul(oneGweiInWei)
let gasLimit = BigNumber.fromInt(1000000)

let txOptions: Float__Contracts.txOptions = {
  maxFeePerGas: maxFeePerGas->BigNumber.toString,
  maxPriorityFeePerGas: maxPriorityFeePerGas->BigNumber.toString,
  gasLimit: gasLimit->BigNumber.toString,
}

let demoReadyOnly = _ => {
  wallet
  ->Wallet.getBalance
  ->Promise.thenResolve(balance => {
    Js.log2("Account balance:", balance->Utils.formatEther)
  })
  ->ignore

  let marketIndex = 1
  let isLong = true
  let sideName = switch isLong {
  | true => "long"
  | false => "short"
  }

  let chain = Float__Chain.WithProvider.makeDefault(chainId)
  chain
  ->Float__Chain.contracts
  ->Promise.thenResolve(c => "LongShort address:"->Js.log2(c.longShort.address))
  ->ignore

  let market = Float__Market.WithProvider.make(provider, marketIndex)

  market
  ->Float__Market.fundingRateMultiplier
  ->Promise.thenResolve(a =>
    "Funding rate multiplier for market "
    ->Js.String2.concat(marketIndex->Js.Int.toString)
    ->Js.String2.concat(":")
    ->Js.log2(a)
  )
  ->ignore

  market
  ->Float__Market.leverage
  ->Promise.thenResolve(m =>
    "Leverage for market "
    ->Js.String2.concat(marketIndex->Js.Int.toString)
    ->Js.String2.concat(":")
    ->Js.log2(m)
  )
  ->ignore

  let marketSide = market->Float__MarketSide.makeUsingMarket(isLong)

  marketSide
  ->Float__MarketSide.poolValue
  ->Promise.thenResolve(a =>
    "Value of marketSide "
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a->BigNumber.toString)
  )
  ->ignore

  marketSide
  ->Float__MarketSide.fundingRateApr
  ->Promise.thenResolve(a =>
    "Funding rate APR for marketSide "
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a)
  )
  ->ignore

  marketSide
  ->Float__MarketSide.exposure
  ->Promise.thenResolve(a =>
    "Exposure of marketSide"
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a->BigNumber.toString)
  )
  ->ignore

  marketSide
  ->Float__MarketSide.unconfirmedExposure
  ->Promise.thenResolve(a =>
    "Unconfirmed exposure of marketSide"
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a->BigNumber.toString)
  )
  ->ignore

  let address = "0x380d3d688fd65ef6858f0e094a1a9bba03ad76a3"
  marketSide
  ->Float__MarketSide.positions(~ethAddress=address, ())
  ->Promise.thenResolve(a =>
    "Synth token amount for 0x38.. in marketSide"
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a.syntheticToken->BigNumber.toString)
  )
  ->ignore
}

let demoWrite = _ => {
  let marketIndex = 1
  let isLong = true
  let sideName = switch isLong {
  | true => "long"
  | false => "short"
  }

  let chain = wallet->Float__Chain.WithWallet.make

  //chain
  //->Float__Chain.updateSystemStateMulti([1], txOptions)
  //->Promise.thenResolve(tx => tx.hash->Js.log)
  //->ignore

  let market = wallet->Float__Market.WithWallet.makeUnwrapped(marketIndex)

  market
  ->Float__Market.settleOutstandingActions(txOptions)
  ->Promise.thenResolve(tx => tx.hash->Js.log)
  ->ignore

  //let side = wallet->Float__MarketSide.WithWallet.make(marketIndex, isLong)

  //side
  //->Float__MarketSide.mint(1->fromInt, txOptions)
  //->Promise.thenResolve(tx => tx.hash->Js.log)
  //->ignore
}

let _ = demoReadyOnly()
