open Float__Ethers
open FloatConfig

let getChainConfigUsingId = chainId =>
  switch FloatConfig.getChainConfig(chainId) {
  | Some(config) => config
  | None => {
      j`Cannot find chain config associated with network ID $chainId, defaulting to Avalanche`->Js.log
      FloatConfig.avalancheConfig
    }
  }

let getChainConfig = (pw: providerOrWallet) =>
  switch pw {
  | P(p) => p
  | W(w) => w.provider
  }
  ->Provider.getNetwork
  ->Promise.thenResolve(network => network.chainId->getChainConfigUsingId)

let makeDefaultProvider = config =>
  config.rpcEndpoint->Provider.JsonRpcProvider.make(~chainId=config.networkId)
