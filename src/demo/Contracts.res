// NOTE: since the type of all of these contracts is a generic `Ethers.Contract.t`, this code can runtime error if the wrong functions are called on the wrong contracts.

module LongShort = {
  type t = Ethers.Contract.t

  type marketSideValue = {
    long: Ethers.BigNumber.t,
    short: Ethers.BigNumber.t,
  }

  // TODO add function modifier keywords
  let abi =
    [
      "function mintLongNextPrice(uint32 marketIndex,uint256 amount)",
      "function mintShortNextPrice(uint32 marketIndex,uint256 amount)",
      "function mintAndStakeNextPrice(uint32 marketIndex,uint256 amount,bool isLong)",
      "function redeemLongNextPrice(uint32 marketIndex,uint256 tokensToRedeem)",
      "function redeemShortNextPrice(uint32 marketIndex,uint256 tokensToRedeem)",
      "function executeOutstandingNextPriceSettlementsUser(address user,uint32 marketIndex)",
      "function updateSystemState()",
      "function updateSystemStateMulti(uint32[] marketIndexes)",
      "function shiftPositionFromLongNextPrice(uint32 marketIndex, uint256 amountSyntheticTokensToShift)",
      "function shiftPositionFromShortNextPrice(uint32 marketIndex, uint256 amountSyntheticTokensToShift)",
      "function get_syntheticToken_priceSnapshot_side(uint32 marketIndex, bool isLong, uint256 priceSnapshotIndex) view returns (uint256 price)",
      "function syntheticTokens(uint32 marketIndex, bool isLong) view returns (address synth)",
      "function marketSideValueInPaymentToken(uint32 marketIndex) view returns (uint128 short, uint128 long)",
    ]->Ethers.makeAbi

  let make = (~address, ~providerOrSigner): t =>
    Ethers.Contract.make(address, abi, providerOrSigner)

  @send
  external mintLongNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintLongNextPrice"
  @send
  external mintShortNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintShortNextPrice"
  @send
  external mintAndStakeNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amount: Ethers.BigNumber.t,
    ~isLong: bool,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mintAndStakeNextPrice"
  @send
  external redeemLongNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~tokensToRedeem: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "redeemLongNextPrice"
  @send
  external redeemShortNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~tokensToRedeem: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "redeemShortNextPrice"
  @send
  external executeOutstandingNextPriceSettlementsUser: (
    ~contract: t,
    ~user: Ethers.ethAddress,
    ~marketIndex: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "executeOutstandingNextPriceSettlementsUser"
  @send
  external updateSystemState: (~contract: t, 'txOptions) => Promise.t<Ethers.txSubmitted> =
    "updateSystemState"
  @send
  external updateSystemStateMulti: (
    ~contract: t,
    ~marketIndexes: array<Ethers.BigNumber.t>,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "updateSystemStateMulti"
  @send
  external shiftPositionFromLongNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountSyntheticTokensToShift: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "shiftPositionFromLongNextPrice"
  @send
  external shiftPositionFromShortNextPrice: (
    ~contract: t,
    ~marketIndex: Ethers.BigNumber.t,
    ~amountSyntheticTokensToShift: Ethers.BigNumber.t,
    'txOptions,
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
}

module Staker = {
  type t = Ethers.Contract.t

  let abi =
    [
      "function stake(address tokenAddress, uint256 amount)",
      "function withdraw(uint32, bool, uint256 amount)",
      "function claimFloatCustom(uint32[] calldata marketIndexes)",
      "function withdrawWithVoucher(uint32 marketIndex, bool isWithdrawFromLong, uint256 withdrawAmount, uint256 expiry, uint256 nonce, uint256 discountWithdrawFee, uint8 v, bytes32 r, bytes32 s)",
      "function shiftTokens(uint256 amountSyntheticTokensToShift, uint32 marketIndex, bool isShiftFromLong)",
      "function userAmountStaked(address, address) public view returns (uint256)",
    ]->Ethers.makeAbi

  let make = (~address, ~providerOrSigner): t =>
    Ethers.Contract.make(address, abi, providerOrSigner)

  @send
  external stake: (
    ~contract: t,
    ~tokenAddress: Ethers.ethAddress,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "stake"
  @send
  external withdraw: (
    ~contract: t,
    ~marketIndex: int,
    ~isWithdrawFromLong: bool,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
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
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "withdrawWithVoucher"
  @send
  external claimFloatCustom: (
    ~contract: t,
    ~marketIndexes: array<int>,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "claimFloatCustom"

  @send
  external shiftTokens: (
    ~contract: t,
    ~amountSyntheticTokensToShift: Ethers.BigNumber.t,
    ~marketIndex: Ethers.BigNumber.t,
    ~isShiftFromLong: bool,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "shiftTokens"

  @send
  external userAmountStaked: (
    ~contract: t,
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

  let make = (~address, ~providerOrSigner): t =>
    Ethers.Contract.make(address, abi, providerOrSigner)

  @send
  external approve: (
    ~contract: t,
    ~spender: Ethers.ethAddress,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
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
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "mint"
}

module Synth = {
  type t = Ethers.Contract.t

  let abi =
    [
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function stake(uint256 amount) external",
      "function totalSupply() external view returns (uint256 total)",
    ]->Ethers.makeAbi

  let make = (address, ~providerOrSigner): t =>
    Ethers.Contract.make(address, abi, providerOrSigner)

  @send
  external approve: (
    ~contract: t,
    ~spender: Ethers.ethAddress,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
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
  external stake: (
    ~contract: t,
    ~amount: Ethers.BigNumber.t,
    'txOptions,
  ) => Promise.t<Ethers.txSubmitted> = "stake"

  @send
  external totalSupply: (
    t,
  ) => Promise.t<Ethers.BigNumber.t> = "totalSupply"
}
