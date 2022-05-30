// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Float__Ethers = require("./Float__Ethers.js");

var abi = Float__Ethers.makeAbi([
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
      "function marketLeverage_e18(uint32 marketIndex) view returns (uint256 leverage)"
    ]);

function make(address, providerOrWallet) {
  return Float__Ethers.Contract.make(address, abi, providerOrWallet);
}

var LongShort = {
  abi: abi,
  make: make
};

var abi$1 = Float__Ethers.makeAbi([
      "function withdraw(uint32 marketIndex, bool isLong, uint256 amountSyntheticToken)",
      "function claimFloatCustom(uint32[] calldata marketIndexes)",
      "function claimFloatCustomFor(uint32[] calldata marketIndexes, address user)",
      "function withdrawWithVoucher(uint32 marketIndex, bool isWithdrawFromLong, uint256 withdrawAmount, uint256 expiry, uint256 nonce, uint256 discountWithdrawFee, uint8 v, bytes32 r, bytes32 s)",
      "function shiftTokens(uint256 amountSyntheticToken, uint32 marketIndex, bool isShiftFromLong)",
      "function userAmountStaked(address, address) public view returns (uint256)"
    ]);

function make$1(address, providerOrWallet) {
  return Float__Ethers.Contract.make(address, abi$1, providerOrWallet);
}

var Staker = {
  abi: abi$1,
  make: make$1
};

var abi$2 = Float__Ethers.makeAbi([
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function mint(uint256 value) public returns (bool)"
    ]);

function make$2(address, providerOrWallet) {
  return Float__Ethers.Contract.make(address, abi$2, providerOrWallet);
}

var Erc20 = {
  abi: abi$2,
  make: make$2
};

var abi$3 = Float__Ethers.makeAbi([
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function stake(uint256 amountSyntheticToken) external",
      "function totalSupply() external view returns (uint256 total)"
    ]);

function make$3(address, providerOrWallet) {
  return Float__Ethers.Contract.make(address, abi$3, providerOrWallet);
}

var Synth = {
  abi: abi$3,
  make: make$3
};

var abi$4 = Float__Ethers.makeAbi(["function mintNFT(uint256 levelId, address receiver) external"]);

function make$4(address, providerOrWallet) {
  return Float__Ethers.Contract.make(address, abi$4, providerOrWallet);
}

var GemCollectorNFT = {
  abi: abi$4,
  make: make$4
};

exports.LongShort = LongShort;
exports.Staker = Staker;
exports.Erc20 = Erc20;
exports.Synth = Synth;
exports.GemCollectorNFT = GemCollectorNFT;
/* abi Not a pure module */