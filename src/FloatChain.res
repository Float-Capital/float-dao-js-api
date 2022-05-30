open FloatContracts
open Promise
open FloatUtil

// ====================================
// Convenience

let {fromInt} = module(FloatEthers.BigNumber)

// ====================================
// Type definitions

type withProvider = {provider: FloatEthers.providerType}
type withWallet = {wallet: FloatEthers.walletType}

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
  p: FloatEthers.providerOrWallet,
  c: FloatConfig.chainConfigShape,
): FloatEthers.Contract.t =>
  LongShort.make(
    ~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let updateSystemStateMulti = (wallet, config, marketIndexes: array<int>) =>
  wallet
  ->FloatEthers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.updateSystemStateMulti(~marketIndexes=marketIndexes->Js.Array2.map(i => i->fromInt))

// TODO add getLongShortImplementationAddress function that fetches the current implentation address

// TODO add getPositions that fetches for all markets

// TODO add settleOutstandingActions that settles for all markets

// ====================================
// Export functions

let contracts = (chain: withProviderOrWalletOrId) =>
  switch chain {
  | P(c) => c.provider->FloatEthers.wrapProvider->getChainConfig
  | W(c) => c.wallet.provider->FloatEthers.wrapProvider->getChainConfig
  }->thenResolve(c => c.contracts)

let updateSystemStateMulti = (chain: withWallet, marketIndexes, txOptions) =>
  chain.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config => chain.wallet->updateSystemStateMulti(config, marketIndexes, txOptions))
