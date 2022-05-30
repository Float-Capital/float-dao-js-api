open Float__Ethers

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

let makeDefaultProvider = (config: FloatConfig.chainConfigShape) =>
  config.rpcEndpoint->Provider.JsonRpcProvider.make(~chainId=config.networkId)

let makeLongShortContract = (p: Float__Ethers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
    Float__Contracts.LongShort.make(
      ~address=c.contracts.longShort.address->Float__Ethers.Utils.getAddressUnsafe,
      ~providerOrWallet=p,
    )

let makeStakerContract = (p: Float__Ethers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
    Float__Contracts.Staker.make(
      ~address=c.contracts.longShort.address->Float__Ethers.Utils.getAddressUnsafe,
      ~providerOrWallet=p,
    )


