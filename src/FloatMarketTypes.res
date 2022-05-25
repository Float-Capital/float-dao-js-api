type withProvider = {provider: FloatEthers.providerType, marketIndex: int}
type withWallet = {wallet: FloatEthers.walletType, marketIndex: int}

type withProviderOrWallet =
  | P(withProvider)
  | W(withWallet)

let wrapMarketP: withProvider => withProviderOrWallet = market => P(market)
let wrapMarketW: withWallet => withProviderOrWallet = market => W(market)
