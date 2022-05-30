// NOTE: since the type of all of these contracts is a generic `contract`, this code can runtime error if the wrong functions are called on the wrong contracts.

let {mul, fromInt, oneGweiInWei, toString} = module(Float__Ethers.BigNumber)

type bn = Float__Ethers.BigNumber.t
type address = Float__Ethers.ethAddress
type contract = Float__Ethers.Contract.t

type txOptionsString = {
  maxFeePerGas: string,
  maxPriorityFeePerGas: string,
  gasLimit: string,
}

type txOptions = {
  maxFeePerGas: int,
  maxPriorityFeePerGas: int,
  gasLimit: int,
}

let convertTxOptions = (input: txOptions): txOptionsString => {
  maxFeePerGas: input.maxFeePerGas->fromInt->mul(oneGweiInWei)->toString,
  maxPriorityFeePerGas: input.maxPriorityFeePerGas->fromInt->mul(oneGweiInWei)->toString,
  gasLimit: input.gasLimit->fromInt->mul(oneGweiInWei)->toString,
}

module LongShort = {
  type t = contract

  type marketSideValue = {
    long: bn,
    short: bn,
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
    ]->Float__Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Float__Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external mintLongNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountPaymentToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "mintLongNextPrice"
  @send
  external mintShortNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountPaymentToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "mintShortNextPrice"
  @send
  external mintAndStakeNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountPaymentToken: bn,
    ~isLong: bool,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "mintAndStakeNextPrice"
  @send
  external redeemLongNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountSyntheticToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "redeemLongNextPrice"
  @send
  external redeemShortNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountSyntheticToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "redeemShortNextPrice"
  @send
  external executeOutstandingNextPriceSettlementsUser: (
    t,
    ~user: address,
    ~marketIndex: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "executeOutstandingNextPriceSettlementsUser"
  @send
  external updateSystemState: (
    t,
    ~marketIndex: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "updateSystemState"
  @send
  external updateSystemStateMulti: (
    t,
    ~marketIndexes: array<bn>,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "updateSystemStateMulti"
  @send
  external shiftPositionFromLongNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountSyntheticToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "shiftPositionFromLongNextPrice"
  @send
  external shiftPositionFromShortNextPrice: (
    t,
    ~marketIndex: bn,
    ~amountSyntheticToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "shiftPositionFromShortNextPrice"
  @send
  external get_syntheticToken_priceSnapshot_side: (
    t,
    ~marketIndex: bn,
    ~isLong: bool,
    ~priceSnapshotIndex: bn,
  ) => Promise.t<bn> = "get_syntheticToken_priceSnapshot_side"
  @send
  external syntheticTokens: (t, ~marketIndex: bn, ~isLong: bool) => Promise.t<address> =
    "syntheticTokens"
  @send
  external marketSideValueInPaymentToken: (t, ~marketIndex: bn) => Promise.t<marketSideValue> =
    "marketSideValueInPaymentToken"
  @send
  external batched_amountPaymentToken_deposit: (
    t,
    ~marketIndex: bn,
    ~isLong: bool,
  ) => Promise.t<bn> = "batched_amountPaymentToken_deposit"
  @send
  external batched_amountSyntheticToken_redeem: (
    t,
    ~marketIndex: bn,
    ~isLong: bool,
  ) => Promise.t<bn> = "batched_amountSyntheticToken_redeem"
  @send
  external batched_amountSyntheticToken_toShiftAwayFrom_marketSide: (
    t,
    ~marketIndex: bn,
    ~isLong: bool,
  ) => Promise.t<bn> = "batched_amountSyntheticToken_toShiftAwayFrom_marketSide"
  @send
  external userNextPrice_currentUpdateIndex: (
    t,
    ~marketIndex: bn,
    ~user: address,
  ) => Promise.t<bn> = "userNextPrice_currentUpdateIndex"
  @send
  external userNextPrice_paymentToken_depositAmount: (
    t,
    ~marketIndex: bn,
    ~isLong: bool,
    ~user: address,
  ) => Promise.t<bn> = "userNextPrice_paymentToken_depositAmount"
  @send
  external getUsersConfirmedButNotSettledSynthBalance: (
    t,
    ~user: address,
    ~marketIndex: bn,
    ~isLong: bool,
  ) => Promise.t<bn> = "getUsersConfirmedButNotSettledSynthBalance"
  @send
  external fundingRateMultiplier_e18: (t, ~marketIndex: bn) => Promise.t<bn> =
    "fundingRateMultiplier_e18"
  @send
  external marketLeverage_e18: (t, ~marketIndex: bn) => Promise.t<bn> = "marketLeverage_e18"
}

module Staker = {
  type t = contract

  let abi =
    [
      "function withdraw(uint32 marketIndex, bool isLong, uint256 amountSyntheticToken)",
      "function claimFloatCustom(uint32[] calldata marketIndexes)",
      "function claimFloatCustomFor(uint32[] calldata marketIndexes, address user)",
      "function withdrawWithVoucher(uint32 marketIndex, bool isWithdrawFromLong, uint256 withdrawAmount, uint256 expiry, uint256 nonce, uint256 discountWithdrawFee, uint8 v, bytes32 r, bytes32 s)",
      "function shiftTokens(uint256 amountSyntheticToken, uint32 marketIndex, bool isShiftFromLong)",
      "function userAmountStaked(address, address) public view returns (uint256)",
    ]->Float__Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Float__Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external withdraw: (
    t,
    ~marketIndex: bn,
    ~isWithdrawFromLong: bool,
    ~amountSyntheticToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "withdraw"
  @send
  external withdrawWithVoucher: (
    ~contract: t,
    ~marketIndex: int,
    ~isWithdrawFromLong: bool,
    ~amount: bn,
    ~expiry: bn,
    ~nonce: bn,
    ~discountWithdrawFee: bn,
    ~v: int,
    ~r: string,
    ~s: string,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "withdrawWithVoucher"
  @send
  external claimFloatCustom: (
    t,
    ~marketIndexes: array<int>,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "claimFloatCustom"
  @send
  external claimFloatCustomFor: (
    t,
    ~marketIndexes: array<bn>,
    ~user: address,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "claimFloatCustomFor"
  @send
  external shiftTokens: (
    t,
    ~amountSyntheticToken: bn,
    ~marketIndex: bn,
    ~isShiftFromLong: bool,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "shiftTokens"
  @send
  external userAmountStaked: (t, ~token: address, ~owner: address) => Promise.t<bn> =
    "userAmountStaked"
}

module Erc20 = {
  type t = contract

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function mint(uint256 value) public returns (bool)",
    ]->Float__Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Float__Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external approve: (
    ~contract: t,
    ~spender: address,
    ~amount: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "approve"

  @send
  external balanceOf: (~contract: t, ~owner: address) => Promise.t<bn> = "balanceOf"

  @send
  external allowance: (~contract: t, ~owner: address, ~spender: address) => Promise.t<bn> =
    "allowance"

  @send
  external mint: (
    ~contract: t,
    ~amount: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "mint"
}

module Synth = {
  type t = contract

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function stake(uint256 amountSyntheticToken) external",
      "function totalSupply() external view returns (uint256 total)",
    ]->Float__Ethers.makeAbi

  let make = (address, ~providerOrWallet): t =>
    Float__Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external approve: (
    ~contract: t,
    ~spender: address,
    ~amount: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "approve"

  @send
  external balanceOf: (t, ~owner: address) => Promise.t<bn> = "balanceOf"

  @send
  external allowance: (~contract: t, ~owner: address, ~spender: address) => Promise.t<bn> =
    "allowance"

  @send
  external stake: (
    t,
    ~amountSyntheticToken: bn,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "stake"

  @send
  external totalSupply: t => Promise.t<bn> = "totalSupply"
}

module GemCollectorNFT = {
  type t = contract

  let abi = ["function mintNFT(uint256 levelId, address receiver) external"]->Float__Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Float__Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external mintNFT: (
    ~contract: t,
    ~levelId: bn,
    ~receiver: address,
    txOptionsString,
  ) => Promise.t<Float__Ethers.txSubmitted> = "mintNFT"
}
