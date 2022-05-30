open Float__Contracts
open Promise
open Float__Util

// ====================================
// Convenience

let {fromInt} = module(Float__Ethers.BigNumber)

// ====================================
// Type definitions

type withProvider = {provider: Float__Ethers.providerType}
type withWallet = {wallet: Float__Ethers.walletType}

type withProviderOrWalletOrId =
  | P(withProvider)
  | W(withWallet)

let wrapChainP: withProvider => withProviderOrWalletOrId = side => P(side)
let wrapChainW: withWallet => withProviderOrWalletOrId = side => W(side)

// ====================================
// Constructors

module WithProvider = {
  type t = withProvider

  // the unwrapped version is not the default but may be useful for rescript consumers
  //   that don't want to have to do a switch statement
  let makeUnwrapped = p => {provider: p}
  let make = p => p->makeUnwrapped->wrapChainP

  // default provider can also be used
  let makeDefault = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->make
  let makeDefaultUnwrapped = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->makeUnwrapped
}

module WithWallet = {
  type t = withWallet
  let makeUnwrapped = w => {wallet: w}
  let make = w => w->makeUnwrapped->wrapChainW
}

// ====================================
// Helper functions

let makeLongShortContract = (
  p: Float__Ethers.providerOrWallet,
  c: FloatConfig.chainConfigShape,
): Float__Ethers.Contract.t =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Float__Ethers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let updateSystemStateMulti = (wallet, config, marketIndexes: array<int>) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.updateSystemStateMulti(~marketIndexes=marketIndexes->Js.Array2.map(i => i->fromInt))

// TODO add getLongShortImplementationAddress function that fetches the current implentation address

// TODO add getPositions that fetches for all markets

// TODO add settleOutstandingActions that settles for all markets

// ====================================
// Export functions

let contracts = (chain: withProviderOrWalletOrId) =>
  switch chain {
  | P(c) => c.provider->Float__Ethers.wrapProvider->getChainConfig
  | W(c) => c.wallet.provider->Float__Ethers.wrapProvider->getChainConfig
  }->thenResolve(c => c.contracts)

let updateSystemStateMulti = (chain: withWallet, marketIndexes, txOptions) =>
  chain.wallet
  ->Float__Ethers.wrapWallet
  ->getChainConfig
  ->then(config => chain.wallet->updateSystemStateMulti(config, marketIndexes, txOptions))
