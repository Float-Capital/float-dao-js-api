// NOTE: since the type of all of these contracts is a generic `FloatEthers.Contract.t`, this code can runtime error if the wrong functions are called on the wrong contracts.

type txOptions = {
  maxFeePerGas: string,
  maxPriorityFeePerGas: string,
  gasLimit: string,
}

module LongShort = {
  type t = FloatEthers.Contract.t

  type marketSideValue = {
    long: FloatEthers.BigNumber.t,
    short: FloatEthers.BigNumber.t,
  }

  let abi =
    [
      "function mintLongNextPrice(uint32 marketIndex,uint256 amountPaymentToken)",
      "function mintShortNextPrice(uint32 marketIndex,uint256 amountPaymentToken)",
      "function mintAndStakeNextPrice(uint32 marketIndex,uint256 amountPaymentToken,bool isLong)",
      "function redeemLongNextPrice(uint32 marketIndex,uint256 amountSyntheticToken)",
      "function redeemShortNextPrice(uint32 marketIndex,uint256 amountSyntheticToken)",
      "function executeOutstandingNextPriceSettlementsUser(address user,uint32 marketIndex)",
      "function updateSystemState(uint32 marketIndex)",
      "function updateSystemStateMulti(uint32[] marketIndexes)",
      "function shiftPositionFromLongNextPrice(uint32 marketIndex, uint256 amountSyntheticToken)",
      "function shiftPositionFromShortNextPrice(uint32 marketIndex, uint256 amountSyntheticToken)",
      "function get_syntheticToken_priceSnapshot_side(uint32 marketIndex, bool isLong, uint256 priceSnapshotIndex) view returns (uint256 price)",
      "function syntheticTokens(uint32 marketIndex, bool isLong) view returns (address synth)",
      "function marketSideValueInPaymentToken(uint32 marketIndex) view returns (uint128 long, uint128 short)",
      "function batched_amountPaymentToken_deposit(uint32 marketIndex, bool isLong) view returns (uint256 amount)",
      "function batched_amountSyntheticToken_redeem(uint32 marketIndex, bool isLong) view returns (uint256 amount)",
      "function batched_amountSyntheticToken_toShiftAwayFrom_marketSide(uint32 marketIndex, bool isLong) view returns (uint256 amount)",
      "function userNextPrice_currentUpdateIndex(uint32 marketIndex, address user) view returns (uint256 amount)",
      "function getUsersConfirmedButNotSettledSynthBalance(address user, uint32 marketIndex, bool isLong) view returns (uint256 amount)",
      "function fundingRateMultiplier_e18(uint32 marketIndex) view returns (uint256 value)",
      "function marketLeverage_e18(uint32 marketIndex) view returns (uint256 leverage)",
    ]->FloatEthers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    FloatEthers.Contract.make(address, abi, providerOrWallet)

  @send
  external mintLongNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountPaymentToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "mintLongNextPrice"
  @send
  external mintShortNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountPaymentToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "mintShortNextPrice"
  @send
  external mintAndStakeNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountPaymentToken: FloatEthers.BigNumber.t,
    ~isLong: bool,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "mintAndStakeNextPrice"
  @send
  external redeemLongNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "redeemLongNextPrice"
  @send
  external redeemShortNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "redeemShortNextPrice"
  @send
  external executeOutstandingNextPriceSettlementsUser: (
    t,
    ~user: FloatEthers.ethAddress,
    ~marketIndex: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "executeOutstandingNextPriceSettlementsUser"
  @send
  external updateSystemState: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "updateSystemState"
  @send
  external updateSystemStateMulti: (
    t,
    ~marketIndexes: array<FloatEthers.BigNumber.t>,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "updateSystemStateMulti"
  @send
  external shiftPositionFromLongNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "shiftPositionFromLongNextPrice"
  @send
  external shiftPositionFromShortNextPrice: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "shiftPositionFromShortNextPrice"
  @send
  external get_syntheticToken_priceSnapshot_side: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
    ~priceSnapshotIndex: FloatEthers.BigNumber.t,
  ) => Promise.t<FloatEthers.BigNumber.t> = "get_syntheticToken_priceSnapshot_side"
  @send
  external syntheticTokens: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<FloatEthers.ethAddress> = "syntheticTokens"
  @send
  external marketSideValueInPaymentToken: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
  ) => Promise.t<marketSideValue> = "marketSideValueInPaymentToken"
  @send
  external batched_amountPaymentToken_deposit: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<FloatEthers.BigNumber.t> = "batched_amountPaymentToken_deposit"
  @send
  external batched_amountSyntheticToken_redeem: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<FloatEthers.BigNumber.t> = "batched_amountSyntheticToken_redeem"
  @send
  external batched_amountSyntheticToken_toShiftAwayFrom_marketSide: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<FloatEthers.BigNumber.t> =
    "batched_amountSyntheticToken_toShiftAwayFrom_marketSide"
  @send
  external userNextPrice_currentUpdateIndex: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~user: FloatEthers.ethAddress,
  ) => Promise.t<FloatEthers.BigNumber.t> = "userNextPrice_currentUpdateIndex"
  @send
  external userNextPrice_paymentToken_depositAmount: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
    ~user: FloatEthers.ethAddress,
  ) => Promise.t<FloatEthers.BigNumber.t> = "userNextPrice_paymentToken_depositAmount"
  @send
  external getUsersConfirmedButNotSettledSynthBalance: (
    t,
    ~user: FloatEthers.ethAddress,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<FloatEthers.BigNumber.t> = "getUsersConfirmedButNotSettledSynthBalance"
  @send
  external fundingRateMultiplier_e18: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
  ) => Promise.t<FloatEthers.BigNumber.t> = "fundingRateMultiplier_e18"
  @send
  external marketLeverage_e18: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
  ) => Promise.t<FloatEthers.BigNumber.t> = "marketLeverage_e18"
}

module Staker = {
  type t = FloatEthers.Contract.t

  let abi =
    [
      "function withdraw(uint32 marketIndex, bool isLong, uint256 amountSyntheticToken)",
      "function claimFloatCustom(uint32[] calldata marketIndexes)",
      "function claimFloatCustomFor(uint32[] calldata marketIndexes, address user)",
      "function withdrawWithVoucher(uint32 marketIndex, bool isWithdrawFromLong, uint256 withdrawAmount, uint256 expiry, uint256 nonce, uint256 discountWithdrawFee, uint8 v, bytes32 r, bytes32 s)",
      "function shiftTokens(uint256 amountSyntheticToken, uint32 marketIndex, bool isShiftFromLong)",
      "function userAmountStaked(address, address) public view returns (uint256)",
    ]->FloatEthers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    FloatEthers.Contract.make(address, abi, providerOrWallet)

  @send
  external withdraw: (
    t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isWithdrawFromLong: bool,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "withdraw"
  @send
  external withdrawWithVoucher: (
    ~contract: t,
    ~marketIndex: int,
    ~isWithdrawFromLong: bool,
    ~amount: FloatEthers.BigNumber.t,
    ~expiry: FloatEthers.BigNumber.t,
    ~nonce: FloatEthers.BigNumber.t,
    ~discountWithdrawFee: FloatEthers.BigNumber.t,
    ~v: int,
    ~r: string,
    ~s: string,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "withdrawWithVoucher"
  @send
  external claimFloatCustom: (
    t,
    ~marketIndexes: array<int>,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "claimFloatCustom"
  @send
  external claimFloatCustomFor: (
    t,
    ~marketIndexes: array<FloatEthers.BigNumber.t>,
    ~user: FloatEthers.ethAddress,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "claimFloatCustomFor"
  @send
  external shiftTokens: (
    t,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    ~marketIndex: FloatEthers.BigNumber.t,
    ~isShiftFromLong: bool,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "shiftTokens"
  @send
  external userAmountStaked: (
    t,
    ~token: FloatEthers.ethAddress,
    ~owner: FloatEthers.ethAddress,
  ) => Promise.t<FloatEthers.BigNumber.t> = "userAmountStaked"
}

module Erc20 = {
  type t = FloatEthers.Contract.t

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function mint(uint256 value) public returns (bool)",
    ]->FloatEthers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    FloatEthers.Contract.make(address, abi, providerOrWallet)

  @send
  external approve: (
    ~contract: t,
    ~spender: FloatEthers.ethAddress,
    ~amount: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "approve"

  @send
  external balanceOf: (
    ~contract: t,
    ~owner: FloatEthers.ethAddress,
  ) => Promise.t<FloatEthers.BigNumber.t> = "balanceOf"

  @send
  external allowance: (
    ~contract: t,
    ~owner: FloatEthers.ethAddress,
    ~spender: FloatEthers.ethAddress,
  ) => Promise.t<FloatEthers.BigNumber.t> = "allowance"

  @send
  external mint: (
    ~contract: t,
    ~amount: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "mint"
}

module Synth = {
  type t = FloatEthers.Contract.t

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function stake(uint256 amountSyntheticToken) external",
      "function totalSupply() external view returns (uint256 total)",
    ]->FloatEthers.makeAbi

  let make = (address, ~providerOrWallet): t =>
    FloatEthers.Contract.make(address, abi, providerOrWallet)

  @send
  external approve: (
    ~contract: t,
    ~spender: FloatEthers.ethAddress,
    ~amount: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "approve"

  @send
  external balanceOf: (t, ~owner: FloatEthers.ethAddress) => Promise.t<FloatEthers.BigNumber.t> =
    "balanceOf"

  @send
  external allowance: (
    ~contract: t,
    ~owner: FloatEthers.ethAddress,
    ~spender: FloatEthers.ethAddress,
  ) => Promise.t<FloatEthers.BigNumber.t> = "allowance"

  @send
  external stake: (
    t,
    ~amountSyntheticToken: FloatEthers.BigNumber.t,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "stake"

  @send
  external totalSupply: t => Promise.t<FloatEthers.BigNumber.t> = "totalSupply"
}

module GemCollectorNFT = {
  type t = FloatEthers.Contract.t

  let abi = ["function mintNFT(uint256 levelId, address receiver) external"]->FloatEthers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    FloatEthers.Contract.make(address, abi, providerOrWallet)

  @send
  external mintNFT: (
    ~contract: t,
    ~levelId: FloatEthers.BigNumber.t,
    ~receiver: FloatEthers.ethAddress,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted> = "mintNFT"
}
