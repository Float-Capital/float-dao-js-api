open FloatContracts
open FloatEthers
open Promise
open FloatUtil

// ====================================
// Type definitions

type withProvider = {provider: FloatEthers.providerType}
type withWallet = {wallet: FloatEthers.walletType}

type withProviderOrWalletOrId =
  | P(withProvider)
  | W(withWallet)

let wrapSideP: withProvider => withProviderOrWalletOrId = side => P(side)
let wrapSideW: withWallet => withProviderOrWalletOrId = side => W(side)

// ====================================
// Constructors

module WithProvider = {
  type t = withProvider
  let make = p => {provider: p}
  let makeWrap = p => p->make->wrapSideP

  // TODO repeat this pattern in Market & Side files
  let makeDefault = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->make
  let makeDefaultWrap = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->makeWrap
}

module WithWallet = {
  type t = withWallet
  let make = w => {wallet: w}
  let makeWrap = w => w->make->wrapSideW
}

// ====================================
// Helper functions

let makeLongShortContract = (
  p: providerOrWallet,
  c: FloatConfig.chainConfigShape,
): FloatEthers.Contract.t =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let updateSystemStateMulti = (
  wallet,
  config,
  marketIndexes: array<BigNumber.t>,
) => wallet->wrapWallet->makeLongShortContract(config)->LongShort.updateSystemStateMulti(~marketIndexes)

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

// TODO turns out that this is not very nice to use as the consumer
let market = (chain: withProviderOrWalletOrId, marketIndex) =>
  switch chain {
  | P(c) => c.provider->FloatMarket.WithProvider.makeWrap(marketIndex)
  | W(c) => c.wallet->FloatMarket.WithWallet.makeWrap(marketIndex)
  }

// TODO repeat this function in Market & Side files (and do the same for other functions that can 'move down a layer')
let updateSystemState = (chain: withWallet, marketIndexes, txOptions) =>
  chain.wallet
  ->wrapWallet
  ->getChainConfig
  ->then(config => chain.wallet->updateSystemStateMulti(config, marketIndexes, txOptions))
