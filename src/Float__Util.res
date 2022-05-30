open Float__Ethers
open FloatConfig

// TODO fix these so that they actually fix the correct config and don't just return ava one
//  first make a function in the config repo that will fetch the correct config given a chainId

let getChainConfig = (pw: providerOrWallet) =>
  switch pw {
  | P(p) => p
  | W(w) => w.provider
  }
  ->Provider.getNetwork
  ->Promise.thenResolve(network => {
    let a = network.chainId
    avalanche
  })

let getChainConfigUsingId = chainId => avalanche

let makeDefaultProvider = config =>
  config.rpcEndopint->Provider.JsonRpcProvider.make(~chainId=config.networkId)
