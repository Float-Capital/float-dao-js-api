// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Ethers = require("ethers");
var Caml_array = require("rescript/lib/js/caml_array.js");
var Ethers$FloatJsClient = require("./demo/Ethers.js");
var CONSTANTS$FloatJsClient = require("./demo/CONSTANTS.js");
var Contracts$FloatJsClient = require("./demo/Contracts.js");
var ConfigMain$FloatJsClient = require("./ConfigMain.js");

var min = Ethers$FloatJsClient.BigNumber.min;

function div(prim0, prim1) {
  return prim0.div(prim1);
}

function mul(prim0, prim1) {
  return prim0.mul(prim1);
}

function add(prim0, prim1) {
  return prim0.add(prim1);
}

function sub(prim0, prim1) {
  return prim0.sub(prim1);
}

function makeLongShortContract(p) {
  return Contracts$FloatJsClient.LongShort.make(Ethers.utils.getAddress(ConfigMain$FloatJsClient.polygonConfig.longShortContractAddress), p);
}

function makeStakerContract(p) {
  return Contracts$FloatJsClient.Staker.make(Ethers.utils.getAddress(ConfigMain$FloatJsClient.polygonConfig.stakerContractAddress), p);
}

function syntheticTokenAddress(p, marketIndex, isLong) {
  return makeLongShortContract(p).syntheticTokens(marketIndex, isLong);
}

function syntheticTokenTotalSupply(p, marketIndex, isLong) {
  return syntheticTokenAddress(p, marketIndex, isLong).then(function (address) {
                return Promise.resolve(Contracts$FloatJsClient.Synth.make(address, p));
              }).then(function (synth) {
              return synth.totalSupply();
            });
}

function syntheticTokenBalance(p, marketIndex, isLong, owner) {
  return syntheticTokenAddress(p, marketIndex, isLong).then(function (address) {
                return Promise.resolve(Contracts$FloatJsClient.Synth.make(address, p));
              }).then(function (synth) {
              return synth.balanceOf(owner);
            });
}

function stakedSyntheticTokenBalance(p, marketIndex, isLong, owner) {
  return syntheticTokenAddress(p, marketIndex, isLong).then(function (token) {
              return makeStakerContract(p).userAmountStaked(token, owner);
            });
}

function marketSideValues(p, marketIndex) {
  return makeLongShortContract(p).marketSideValueInPaymentToken(marketIndex);
}

function marketSideValue(p, marketIndex, isLong) {
  return makeLongShortContract(p).marketSideValueInPaymentToken(marketIndex).then(function (marketSideValue) {
              if (isLong) {
                return marketSideValue.long;
              } else {
                return marketSideValue.short;
              }
            });
}

function updateIndex(p, marketIndex, user) {
  return makeLongShortContract(p).userNextPrice_currentUpdateIndex(marketIndex, user);
}

function unsettledSynthBalance(p, marketIndex, isLong, user) {
  return makeLongShortContract(p).getUsersConfirmedButNotSettledSynthBalance(user, marketIndex, isLong);
}

function marketSideUnconfirmedDeposits(p, marketIndex, isLong) {
  return makeLongShortContract(p).batched_amountPaymentToken_deposit(marketIndex, isLong);
}

function marketSideUnconfirmedRedeems(p, marketIndex, isLong) {
  return makeLongShortContract(p).batched_amountSyntheticToken_redeem(marketIndex, isLong);
}

function marketSideUnconfirmedShifts(p, marketIndex, isShiftFromLong) {
  return makeLongShortContract(p).batched_amountSyntheticToken_toShiftAwayFrom_marketSide(marketIndex, isShiftFromLong);
}

function syntheticTokenPrice(p, marketIndex, isLong) {
  return Promise.all([
                marketSideValue(p, marketIndex, isLong),
                syntheticTokenTotalSupply(p, marketIndex, isLong)
              ]).then(function (param) {
              return param[0].mul(CONSTANTS$FloatJsClient.tenToThe18).div(param[1]);
            });
}

function syntheticTokenPriceSnapshot(p, marketIndex, isLong, priceSnapshotIndex) {
  return makeLongShortContract(p).get_syntheticToken_priceSnapshot_side(marketIndex, isLong, priceSnapshotIndex);
}

function exposure(p, marketIndex, isLong) {
  return makeLongShortContract(p).marketSideValueInPaymentToken(marketIndex).then(function (values) {
              var numerator = min(values.long, values.short).mul(CONSTANTS$FloatJsClient.tenToThe18);
              if (isLong) {
                return numerator.div(values.long);
              } else {
                return numerator.div(values.short);
              }
            });
}

function unconfirmedExposure(p, marketIndex, isLong) {
  return Promise.all([
                syntheticTokenPrice(p, marketIndex, true),
                syntheticTokenPrice(p, marketIndex, false),
                marketSideUnconfirmedRedeems(p, marketIndex, true),
                marketSideUnconfirmedRedeems(p, marketIndex, false),
                marketSideUnconfirmedShifts(p, marketIndex, true),
                marketSideUnconfirmedShifts(p, marketIndex, false),
                marketSideUnconfirmedDeposits(p, marketIndex, true),
                marketSideUnconfirmedDeposits(p, marketIndex, false),
                marketSideValue(p, marketIndex, true),
                marketSideValue(p, marketIndex, false)
              ]).then(function (results) {
              var priceLong = Caml_array.get(results, 0);
              var priceShort = Caml_array.get(results, 1);
              var redeemsLong = Caml_array.get(results, 2);
              var redeemsShort = Caml_array.get(results, 3);
              var shiftsFromLong = Caml_array.get(results, 4);
              var shiftsFromShort = Caml_array.get(results, 5);
              var depositsLong = Caml_array.get(results, 6);
              var depositsShort = Caml_array.get(results, 7);
              var valueLong = Caml_array.get(results, 8);
              var valueShort = Caml_array.get(results, 9);
              var unconfirmedValueLong = shiftsFromShort.sub(shiftsFromLong).sub(redeemsLong).mul(priceLong).div(CONSTANTS$FloatJsClient.tenToThe18).add(depositsLong).add(valueLong);
              var unconfirmedValueShort = shiftsFromLong.sub(shiftsFromShort).sub(redeemsShort).mul(priceShort).div(CONSTANTS$FloatJsClient.tenToThe18).add(depositsShort).add(valueShort);
              var numerator = min(unconfirmedValueLong, unconfirmedValueShort).mul(CONSTANTS$FloatJsClient.tenToThe18);
              if (isLong) {
                return numerator.div(unconfirmedValueLong);
              } else {
                return numerator.div(unconfirmedValueShort);
              }
            });
}

function positions(p, marketIndex, isLong, address) {
  return Promise.all([
                syntheticTokenBalance(p, marketIndex, isLong, address),
                syntheticTokenPrice(p, marketIndex, isLong)
              ]).then(function (param) {
              var balance = param[0];
              return {
                      paymentToken: balance.mul(param[1]),
                      synthToken: balance
                    };
            });
}

function stakedPositions(p, marketIndex, isLong, address) {
  return Promise.all([
                stakedSyntheticTokenBalance(p, marketIndex, isLong, address),
                syntheticTokenPrice(p, marketIndex, isLong)
              ]).then(function (param) {
              var balance = param[0];
              return {
                      paymentToken: balance.mul(param[1]),
                      synthToken: balance
                    };
            });
}

function unsettledPositions(p, marketIndex, isLong, address) {
  return updateIndex(p, marketIndex, address).then(function (index) {
                return Promise.all([
                            syntheticTokenPriceSnapshot(p, marketIndex, isLong, index),
                            unsettledSynthBalance(p, marketIndex, isLong, address)
                          ]);
              }).then(function (param) {
              var balance = param[1];
              return {
                      paymentToken: balance.mul(param[0]),
                      synthToken: balance
                    };
            });
}

function mint(p, marketIndex, isLong, amountPaymentToken) {
  if (isLong) {
    var partial_arg = makeLongShortContract(p);
    return function (param) {
      return partial_arg.mintLongNextPrice(marketIndex, amountPaymentToken, param);
    };
  }
  var partial_arg$1 = makeLongShortContract(p);
  return function (param) {
    return partial_arg$1.mintShortNextPrice(marketIndex, amountPaymentToken, param);
  };
}

function mintAndStake(p, marketIndex, isLong, amountPaymentToken) {
  var partial_arg = makeLongShortContract(p);
  return function (param) {
    return partial_arg.mintAndStakeNextPrice(marketIndex, amountPaymentToken, isLong, param);
  };
}

function stake(p, marketIndex, isLong, amountSyntheticToken, txOptions) {
  return syntheticTokenAddress(p, marketIndex, isLong).then(function (address) {
                return Promise.resolve(Contracts$FloatJsClient.Synth.make(address, p));
              }).then(function (synth) {
              return synth.stake(amountSyntheticToken, txOptions);
            });
}

function unstake(p, marketIndex, isLong, amountSyntheticToken) {
  var partial_arg = makeStakerContract(p);
  return function (param) {
    return partial_arg.withdraw(marketIndex, isLong, amountSyntheticToken, param);
  };
}

function redeem(p, marketIndex, isLong, amountSyntheticToken) {
  if (isLong) {
    var partial_arg = makeLongShortContract(p);
    return function (param) {
      return partial_arg.redeemLongNextPrice(marketIndex, amountSyntheticToken, param);
    };
  }
  var partial_arg$1 = makeLongShortContract(p);
  return function (param) {
    return partial_arg$1.redeemShortNextPrice(marketIndex, amountSyntheticToken, param);
  };
}

function shift(p, marketIndex, isLong, amountSyntheticToken) {
  if (isLong) {
    var partial_arg = makeLongShortContract(p);
    return function (param) {
      return partial_arg.shiftPositionFromLongNextPrice(marketIndex, amountSyntheticToken, param);
    };
  }
  var partial_arg$1 = makeLongShortContract(p);
  return function (param) {
    return partial_arg$1.shiftPositionFromLongNextPrice(marketIndex, amountSyntheticToken, param);
  };
}

function shiftStake(p, marketIndex, isLong, amountSyntheticToken) {
  var partial_arg = makeStakerContract(p);
  return function (param) {
    return partial_arg.shiftTokens(amountSyntheticToken, marketIndex, isLong, param);
  };
}

function newFloatMarketSide(p, marketIndex, isLong) {
  return {
          getSyntheticTokenPrice: (function (param) {
              return syntheticTokenPrice(p, marketIndex, isLong);
            }),
          getExposure: (function (param) {
              return exposure(p, marketIndex, isLong);
            }),
          getUnconfirmedExposure: (function (param) {
              return unconfirmedExposure(p, marketIndex, isLong);
            }),
          getPositions: (function (param) {
              return positions(p, marketIndex, isLong, param);
            }),
          getStakedPositions: (function (param) {
              return stakedPositions(p, marketIndex, isLong, param);
            }),
          getUnsettledPositions: (function (param) {
              return unsettledPositions(p, marketIndex, isLong, param);
            }),
          mint: (function (param) {
              return mint(p, marketIndex, isLong, param);
            }),
          mintAndStake: (function (param) {
              return mintAndStake(p, marketIndex, isLong, param);
            }),
          stake: (function (param, param$1) {
              return stake(p, marketIndex, isLong, param, param$1);
            }),
          unstake: (function (param) {
              return unstake(p, marketIndex, isLong, param);
            }),
          redeem: (function (param) {
              return redeem(p, marketIndex, isLong, param);
            }),
          shift: (function (param) {
              return shift(p, marketIndex, isLong, param);
            }),
          shiftStake: (function (param) {
              return shiftStake(p, marketIndex, isLong, param);
            })
        };
}

var MarketSide = {
  makeLongShortContract: makeLongShortContract,
  makeStakerContract: makeStakerContract,
  syntheticTokenAddress: syntheticTokenAddress,
  syntheticTokenTotalSupply: syntheticTokenTotalSupply,
  syntheticTokenBalance: syntheticTokenBalance,
  stakedSyntheticTokenBalance: stakedSyntheticTokenBalance,
  marketSideValues: marketSideValues,
  marketSideValue: marketSideValue,
  updateIndex: updateIndex,
  unsettledSynthBalance: unsettledSynthBalance,
  marketSideUnconfirmedDeposits: marketSideUnconfirmedDeposits,
  marketSideUnconfirmedRedeems: marketSideUnconfirmedRedeems,
  marketSideUnconfirmedShifts: marketSideUnconfirmedShifts,
  syntheticTokenPrice: syntheticTokenPrice,
  syntheticTokenPriceSnapshot: syntheticTokenPriceSnapshot,
  exposure: exposure,
  unconfirmedExposure: unconfirmedExposure,
  positions: positions,
  stakedPositions: stakedPositions,
  unsettledPositions: unsettledPositions,
  mint: mint,
  mintAndStake: mintAndStake,
  stake: stake,
  unstake: unstake,
  redeem: redeem,
  shift: shift,
  shiftStake: shiftStake,
  newFloatMarketSide: newFloatMarketSide
};

exports.min = min;
exports.div = div;
exports.mul = mul;
exports.add = add;
exports.sub = sub;
exports.MarketSide = MarketSide;
/* ethers Not a pure module */
