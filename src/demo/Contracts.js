// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Ethers$FloatJsClient = require("./Ethers.js");

var abi = Ethers$FloatJsClient.makeAbi([
      "function mintLongNextPrice(uint32 marketIndex,uint256 amount)",
      "function mintShortNextPrice(uint32 marketIndex,uint256 amount)",
      "function mintAndStakeNextPrice(uint32 marketIndex,uint256 amount,bool isLong)",
      "function redeemLongNextPrice(uint32 marketIndex,uint256 tokensToRedeem)",
      "function redeemShortNextPrice(uint32 marketIndex,uint256 tokensToRedeem)",
      "function executeOutstandingNextPriceSettlementsUser(address user,uint32 marketIndex)",
      "function updateSystemState()",
      "function updateSystemStateMulti(uint32[] marketIndexes)",
      "function shiftPositionFromLongNextPrice(uint32 marketIndex, uint256 amountSyntheticTokensToShift)",
      "function shiftPositionFromShortNextPrice(uint32 marketIndex, uint256 amountSyntheticTokensToShift)"
    ]);

function make(address, providerOrSigner) {
  return Ethers$FloatJsClient.Contract.make(address, abi, providerOrSigner);
}

var LongShort = {
  abi: abi,
  make: make
};

var abi$1 = Ethers$FloatJsClient.makeAbi([
      "function stake(address tokenAddress, uint256 amount)",
      "function withdraw(uint32, bool, uint256 amount)",
      "function claimFloatCustom(uint32[] calldata marketIndexes)",
      "function withdrawWithVoucher(uint32 marketIndex, bool isWithdrawFromLong, uint256 withdrawAmount, uint256 expiry, uint256 nonce, uint256 discountWithdrawFee, uint8 v, bytes32 r, bytes32 s)",
      "function shiftTokens(uint256 amountSyntheticTokensToShift, uint32 marketIndex, bool isShiftFromLong)",
      "function userAmountStaked(address, address) public view returns (uint256)"
    ]);

function make$1(address, providerOrSigner) {
  return Ethers$FloatJsClient.Contract.make(address, abi$1, providerOrSigner);
}

var Staker = {
  abi: abi$1,
  make: make$1
};

var abi$2 = Ethers$FloatJsClient.makeAbi([
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function mint(uint256 value) public returns (bool)"
    ]);

function make$2(address, providerOrSigner) {
  return Ethers$FloatJsClient.Contract.make(address, abi$2, providerOrSigner);
}

var Erc20 = {
  abi: abi$2,
  make: make$2
};

var abi$3 = Ethers$FloatJsClient.makeAbi([
      "function approve(address spender, uint256 amount)",
      "function balanceOf(address owner) public view returns (uint256 balance)",
      "function allowance(address owner, address spender) public view returns (uint256 remaining)",
      "function stake(uint256 amount) external"
    ]);

function make$3(address, providerOrSigner) {
  return Ethers$FloatJsClient.Contract.make(address, abi$3, providerOrSigner);
}

var Synth = {
  abi: abi$3,
  make: make$3
};

var abi$4 = Ethers$FloatJsClient.makeAbi(["function mintNFT(uint256 levelId, address receiver) external"]);

function make$4(address, providerOrSigner) {
  return Ethers$FloatJsClient.Contract.make(address, abi$4, providerOrSigner);
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
