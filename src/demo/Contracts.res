// NOTE: since the type of all of these contracts is a generic `Ethers.Contract.t`, this code can runtime error if the wrong functions are called on the wrong contracts.

type txOptions = {
  maxFeePerGas: string,
  maxPriorityFeePerGas: string,
  gasLimit: string,
}

module LongShort = {
  type t = Ethers.Contract.t

  type marketSideValue = {
    long: Ethers.BigNumber.t,
    short: Ethers.BigNumber.t,
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
    ]->Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external mintLongNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountPaymentToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintLongNextPrice"
  @send
  external mintShortNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountPaymentToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintShortNextPrice"
  @send
  external mintAndStakeNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountPaymentToken: Ethers.BigNumber.t,
    ~isLong: bool,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintAndStakeNextPrice"
  @send
  external redeemLongNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "redeemLongNextPrice"
  @send
  external redeemShortNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "redeemShortNextPrice"
  @send
  external executeOutstandingNextPriceSettlementsUser: (
    t,
    ~user: Ethers.ethAddress,
    ~marketIndex: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "executeOutstandingNextPriceSettlementsUser"
  @send
  external updateSystemState: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    txOptions
  ) => Promise.t<Ethers.txSubmitted> = "updateSystemState"
  @send
  external updateSystemStateMulti: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "updateSystemStateMulti"
  @send
  external shiftPositionFromLongNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "shiftPositionFromLongNextPrice"
  @send
  external shiftPositionFromShortNextPrice: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "shiftPositionFromShortNextPrice"
  @send
  external get_syntheticToken_priceSnapshot_side: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
    ~priceSnapshotIndex: Ethers.BigNumber.t,
  ) => Promise.t<Ethers.BigNumber.t> = "get_syntheticToken_priceSnapshot_side"
  @send
  external syntheticTokens: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<Ethers.ethAddress> = "syntheticTokens"
  @send
  external marketSideValueInPaymentToken: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
  ) => Promise.t<marketSideValue> = "marketSideValueInPaymentToken"
  @send
  external batched_amountPaymentToken_deposit: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<Ethers.BigNumber.t> = "batched_amountPaymentToken_deposit"
  @send
  external batched_amountSyntheticToken_redeem: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<Ethers.BigNumber.t> = "batched_amountSyntheticToken_redeem"
  @send
  external batched_amountSyntheticToken_toShiftAwayFrom_marketSide: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<Ethers.BigNumber.t> = "batched_amountSyntheticToken_toShiftAwayFrom_marketSide"
  @send
  external userNextPrice_currentUpdateIndex: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~user: Ethers.ethAddress,
  ) => Promise.t<Ethers.BigNumber.t> = "userNextPrice_currentUpdateIndex"
  @send
  external userNextPrice_paymentToken_depositAmount: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
    ~user: Ethers.ethAddress,
  ) => Promise.t<Ethers.BigNumber.t> = "userNextPrice_paymentToken_depositAmount"
  @send
  external getUsersConfirmedButNotSettledSynthBalance: (
    t,
    ~user: Ethers.ethAddress,
    ~marketIndex: Ethers.BigNumber.t,
    ~isLong: bool,
  ) => Promise.t<Ethers.BigNumber.t> = "getUsersConfirmedButNotSettledSynthBalance"
  @send
  external fundingRateMultiplier_e18: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
  ) => Promise.t<Ethers.BigNumber.t> = "fundingRateMultiplier_e18"
  @send
  external marketLeverage_e18: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
  ) => Promise.t<Ethers.BigNumber.t> = "marketLeverage_e18"
}

module Staker = {
  type t = Ethers.Contract.t

  let abi =
    [
      "function withdraw(uint32 marketIndex, bool isLong, uint256 amountSyntheticToken)",
      "function claimFloatCustom(uint32[] calldata marketIndexes)",
      "function claimFloatCustomFor(uint32[] calldata marketIndexes, address user)",
      "function withdrawWithVoucher(uint32 marketIndex, bool isWithdrawFromLong, uint256 withdrawAmount, uint256 expiry, uint256 nonce, uint256 discountWithdrawFee, uint8 v, bytes32 r, bytes32 s)",
      "function shiftTokens(uint256 amountSyntheticToken, uint32 marketIndex, bool isShiftFromLong)",
      "function userAmountStaked(address, address) public view returns (uint256)",
    ]->Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external withdraw: (
    t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isWithdrawFromLong: bool,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "withdraw"
  @send
  external withdrawWithVoucher: (
    ~contract: t,
    ~marketIndex: int,
    ~isWithdrawFromLong: bool,
    ~amount: Ethers.BigNumber.t,
    ~expiry: Ethers.BigNumber.t,
    ~nonce: Ethers.BigNumber.t,
    ~discountWithdrawFee: Ethers.BigNumber.t,
    ~v: int,
    ~r: string,
    ~s: string,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "withdrawWithVoucher"
  @send
  external claimFloatCustom: (
    t,
    ~marketIndexes: array<int>,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "claimFloatCustom"
  @send
  external claimFloatCustomFor: (
    t,
    ~marketIndexes: array<Ethers.BigNumber.t>,
    ~user: Ethers.ethAddress,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "claimFloatCustomFor"
  @send
  external shiftTokens: (
    t,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isShiftFromLong: bool,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "shiftTokens"
  @send
  external userAmountStaked: (
    t,
    ~token: Ethers.ethAddress,
    ~owner: Ethers.ethAddress,
  ) => Promise.t<Ethers.BigNumber.t> = "userAmountStaked"
}

module Erc20 = {
  type t = Ethers.Contract.t

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function mint(uint256 value) public returns (bool)",
    ]->Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external approve: (
    ~contract: t,
    ~spender: Ethers.ethAddress,
    ~amount: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "approve"

  @send
  external balanceOf: (~contract: t, ~owner: Ethers.ethAddress) => Promise.t<Ethers.BigNumber.t> =
    "balanceOf"

  @send
  external allowance: (
    ~contract: t,
    ~owner: Ethers.ethAddress,
    ~spender: Ethers.ethAddress,
  ) => Promise.t<Ethers.BigNumber.t> = "allowance"

  @send
  external mint: (
    ~contract: t,
    ~amount: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mint"
}

module Synth = {
  type t = Ethers.Contract.t

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function stake(uint256 amountSyntheticToken) external",
      "function totalSupply() external view returns (uint256 total)",
    ]->Ethers.makeAbi

  let make = (address, ~providerOrWallet): t => Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external approve: (
    ~contract: t,
    ~spender: Ethers.ethAddress,
    ~amount: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "approve"

  @send
  external balanceOf: (t, ~owner: Ethers.ethAddress) => Promise.t<Ethers.BigNumber.t> = "balanceOf"

  @send
  external allowance: (
    ~contract: t,
    ~owner: Ethers.ethAddress,
    ~spender: Ethers.ethAddress,
  ) => Promise.t<Ethers.BigNumber.t> = "allowance"

  @send
  external stake: (
    t,
    ~amountSyntheticToken: Ethers.BigNumber.t,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "stake"

  @send
  external totalSupply: t => Promise.t<Ethers.BigNumber.t> = "totalSupply"
}

module GemCollectorNFT = {
  type t = Ethers.Contract.t

  let abi = ["function mintNFT(uint256 levelId, address receiver) external"]->Ethers.makeAbi

  let make = (~address, ~providerOrWallet): t =>
    Ethers.Contract.make(address, abi, providerOrWallet)

  @send
  external mintNFT: (
    ~contract: t,
    ~levelId: Ethers.BigNumber.t,
    ~receiver: Ethers.ethAddress,
    txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintNFT"
}
