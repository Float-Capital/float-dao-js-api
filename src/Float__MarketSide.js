// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Ethers = require("ethers");
var Caml_array = require("rescript/lib/js/caml_array.js");
var Float__Util = require("./Float__Util.js");
var Float__Ethers = require("./Float__Ethers.js");
var Float__Contracts = require("./Float__Contracts.js");
var Float__Market__shared = require("./Float__Market__shared.js");

var min = Float__Ethers.BigNumber.min;

var max = Float__Ethers.BigNumber.max;

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

function fromInt(prim) {
  return Ethers.BigNumber.from(prim);
}

function fromFloat(prim) {
  return Ethers.BigNumber.from(prim);
}

function toNumber(prim) {
  return prim.toNumber();
}

function toNumberFloat(prim) {
  return prim.toNumber();
}

var tenToThe18 = Float__Ethers.BigNumber.tenToThe18;

var tenToThe14 = Float__Ethers.BigNumber.tenToThe14;

function wrapSideP(side) {
  return {
          TAG: /* P */0,
          _0: side
        };
}

function wrapSideW(side) {
  return {
          TAG: /* W */1,
          _0: side
        };
}

function makeUnwrapped(p, marketIndex, isLong) {
  return {
          provider: p,
          marketIndex: marketIndex,
          isLong: isLong
        };
}

function make(p, marketIndex, isLong) {
  return {
          TAG: /* P */0,
          _0: {
            provider: p,
            marketIndex: marketIndex,
            isLong: isLong
          }
        };
}

function makeReverseCurry(isLong, marketIndex, p) {
  return {
          TAG: /* P */0,
          _0: {
            provider: p,
            marketIndex: marketIndex,
            isLong: isLong
          }
        };
}

function makeDefault(chainId) {
  var partial_arg = Float__Util.makeDefaultProvider(Float__Util.getChainConfigUsingId(chainId));
  return function (param, param$1) {
    return make(partial_arg, param, param$1);
  };
}

function makeDefaultUnwrapped(chainId) {
  var partial_arg = Float__Util.makeDefaultProvider(Float__Util.getChainConfigUsingId(chainId));
  return function (param, param$1) {
    return {
            provider: partial_arg,
            marketIndex: param,
            isLong: param$1
          };
  };
}

var WithProvider = {
  makeUnwrapped: makeUnwrapped,
  make: make,
  makeReverseCurry: makeReverseCurry,
  makeDefault: makeDefault,
  makeDefaultUnwrapped: makeDefaultUnwrapped
};

function makeUnwrapped$1(w, marketIndex, isLong) {
  return {
          wallet: w,
          marketIndex: marketIndex,
          isLong: isLong
        };
}

function make$1(w, marketIndex, isLong) {
  return {
          TAG: /* W */1,
          _0: {
            wallet: w,
            marketIndex: marketIndex,
            isLong: isLong
          }
        };
}

var WithWallet = {
  makeUnwrapped: makeUnwrapped$1,
  make: make$1
};

function makeUsingMarket(market, isLong) {
  if (market.TAG === /* P */0) {
    var m = market._0;
    return make(m.provider, m.marketIndex, isLong);
  }
  var m$1 = market._0;
  return make$1(m$1.wallet, m$1.marketIndex, isLong);
}

function provider(side) {
  if (side.TAG === /* P */0) {
    return side._0.provider;
  } else {
    return side._0.wallet.provider;
  }
}

function syntheticTokenAddress(provider, config, marketIndex, isLong) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).syntheticTokens(marketIndex, isLong);
}

function syntheticTokenTotalSupply(provider, config, marketIndex, isLong) {
  return syntheticTokenAddress(provider, config, marketIndex, isLong).then(function (address) {
                return Promise.resolve(Float__Contracts.Synth.make(address, Float__Ethers.wrapProvider(provider)));
              }).then(function (synth) {
              return synth.totalSupply();
            });
}

function syntheticTokenBalance(provider, config, marketIndex, isLong, owner) {
  return syntheticTokenAddress(provider, config, marketIndex, isLong).then(function (address) {
                return Promise.resolve(Float__Contracts.Synth.make(address, Float__Ethers.wrapProvider(provider)));
              }).then(function (synth) {
              return synth.balanceOf(owner);
            });
}

function stakedSyntheticTokenBalance(provider, config, marketIndex, isLong, owner) {
  return syntheticTokenAddress(provider, config, marketIndex, isLong).then(function (token) {
              return Float__Util.makeStakerContract(Float__Ethers.wrapProvider(provider), config).userAmountStaked(token, owner);
            });
}

function marketSideValue(provider, config, marketIndex, isLong) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).marketSideValueInPaymentToken(marketIndex).then(function (value) {
              if (isLong) {
                return value.long;
              } else {
                return value.short;
              }
            });
}

function updateIndex(provider, config, marketIndex, user) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).userNextPrice_currentUpdateIndex(marketIndex, user);
}

function unsettledSynthBalance(provider, config, marketIndex, isLong, user) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).getUsersConfirmedButNotSettledSynthBalance(user, marketIndex, isLong);
}

function marketSideUnconfirmedDeposits(provider, config, marketIndex, isLong) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).batched_amountPaymentToken_deposit(marketIndex, isLong);
}

function marketSideUnconfirmedRedeems(provider, config, marketIndex, isLong) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).batched_amountSyntheticToken_redeem(marketIndex, isLong);
}

function marketSideUnconfirmedShifts(provider, config, marketIndex, isShiftFromLong) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).batched_amountSyntheticToken_toShiftAwayFrom_marketSide(marketIndex, isShiftFromLong);
}

function syntheticTokenPrice(provider, config, marketIndex, isLong) {
  return Promise.all([
                marketSideValue(provider, config, marketIndex, isLong),
                syntheticTokenTotalSupply(provider, config, marketIndex, isLong)
              ]).then(function (param) {
              return param[0].mul(tenToThe18).div(param[1]);
            });
}

function syntheticTokenPriceSnapshot(provider, config, marketIndex, isLong, priceSnapshotIndex) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).get_syntheticToken_priceSnapshot_side(marketIndex, isLong, priceSnapshotIndex);
}

function marketSideValues(provider, config, marketIndex) {
  return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider), config).marketSideValueInPaymentToken(marketIndex);
}

function mint(wallet, config, marketIndex, isLong, amountPaymentToken) {
  if (isLong) {
    var partial_arg = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
    return function (param) {
      return partial_arg.mintLongNextPrice(marketIndex, amountPaymentToken, param);
    };
  }
  var partial_arg$1 = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg$1.mintShortNextPrice(marketIndex, amountPaymentToken, param);
  };
}

function mintAndStake(wallet, config, marketIndex, isLong, amountPaymentToken) {
  var partial_arg = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg.mintAndStakeNextPrice(marketIndex, amountPaymentToken, isLong, param);
  };
}

function unstake(wallet, config, marketIndex, isLong, amountSyntheticToken) {
  var partial_arg = Float__Util.makeStakerContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg.withdraw(marketIndex, isLong, amountSyntheticToken, param);
  };
}

function redeem(wallet, config, marketIndex, isLong, amountSyntheticToken) {
  if (isLong) {
    var partial_arg = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
    return function (param) {
      return partial_arg.redeemLongNextPrice(marketIndex, amountSyntheticToken, param);
    };
  }
  var partial_arg$1 = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg$1.redeemShortNextPrice(marketIndex, amountSyntheticToken, param);
  };
}

function shift(wallet, config, marketIndex, isLong, amountSyntheticToken) {
  if (isLong) {
    var partial_arg = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
    return function (param) {
      return partial_arg.shiftPositionFromLongNextPrice(marketIndex, amountSyntheticToken, param);
    };
  }
  var partial_arg$1 = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg$1.shiftPositionFromShortNextPrice(marketIndex, amountSyntheticToken, param);
  };
}

function shiftStake(wallet, config, marketIndex, isLong, amountSyntheticToken) {
  var partial_arg = Float__Util.makeStakerContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg.shiftTokens(amountSyntheticToken, marketIndex, isLong, param);
  };
}

function syntheticToken(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              if (side._0.isLong) {
                return Caml_array.get(config.markets, side._0.marketIndex).longToken;
              } else {
                return Caml_array.get(config.markets, side._0.marketIndex).shortToken;
              }
            });
}

function name(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (param) {
              if (side._0.isLong) {
                return "long";
              } else {
                return "short";
              }
            });
}

function poolValue(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              return marketSideValue(provider(side), config, Ethers.BigNumber.from(side._0.marketIndex), side._0.isLong);
            });
}

function syntheticTokenPrice$1(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              return syntheticTokenPrice(provider(side), config, Ethers.BigNumber.from(side._0.marketIndex), side._0.isLong);
            });
}

function exposure(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              var provider$1 = provider(side);
              var marketIndex = Ethers.BigNumber.from(side._0.marketIndex);
              var isLong = side._0.isLong;
              return marketSideValues(provider$1, config, marketIndex).then(function (values) {
                          var numerator = min(values.long, values.short).mul(tenToThe18);
                          if (isLong) {
                            return numerator.div(values.long);
                          } else {
                            return numerator.div(values.short);
                          }
                        });
            });
}

function unconfirmedExposure(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              var provider$1 = provider(side);
              var marketIndex = Ethers.BigNumber.from(side._0.marketIndex);
              var isLong = side._0.isLong;
              return Promise.all([
                            syntheticTokenPrice(provider$1, config, marketIndex, true),
                            syntheticTokenPrice(provider$1, config, marketIndex, false),
                            marketSideUnconfirmedRedeems(provider$1, config, marketIndex, true),
                            marketSideUnconfirmedRedeems(provider$1, config, marketIndex, false),
                            marketSideUnconfirmedShifts(provider$1, config, marketIndex, true),
                            marketSideUnconfirmedShifts(provider$1, config, marketIndex, false),
                            marketSideUnconfirmedDeposits(provider$1, config, marketIndex, true),
                            marketSideUnconfirmedDeposits(provider$1, config, marketIndex, false),
                            marketSideValue(provider$1, config, marketIndex, true),
                            marketSideValue(provider$1, config, marketIndex, false)
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
                          var unconfirmedValueLong = shiftsFromShort.sub(shiftsFromLong).sub(redeemsLong).mul(priceLong).div(tenToThe18).add(depositsLong).add(valueLong);
                          var unconfirmedValueShort = shiftsFromLong.sub(shiftsFromShort).sub(redeemsShort).mul(priceShort).div(tenToThe18).add(depositsShort).add(valueShort);
                          var numerator = min(unconfirmedValueLong, unconfirmedValueShort).mul(tenToThe18);
                          if (isLong) {
                            return numerator.div(unconfirmedValueLong);
                          } else {
                            return numerator.div(unconfirmedValueShort);
                          }
                        });
            });
}

function fundingRateApr(side) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              var provider$1 = provider(side);
              var marketIndex = Ethers.BigNumber.from(side._0.marketIndex);
              var isLong = side._0.isLong;
              return Promise.all([
                            Float__Market__shared.fundingRateMultiplier(provider$1, config, marketIndex),
                            marketSideValues(provider$1, config, marketIndex)
                          ]).then(function (param) {
                          var match = param[1];
                          var $$short = match.short;
                          var $$long = match.long;
                          return $$short.sub($$long).mul(Ethers.BigNumber.from(isLong ? 1 : -1)).mul(param[0]).div(isLong ? $$long : $$short);
                        });
            });
}

function positions(side, ethAddress, param) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              var address;
              if (ethAddress !== undefined) {
                address = ethAddress;
              } else if (side.TAG === /* P */0) {
                console.log("No address found");
                address = "";
              } else {
                address = side._0.wallet.address;
              }
              var provider$1 = provider(side);
              var marketIndex = Ethers.BigNumber.from(side._0.marketIndex);
              var isLong = side._0.isLong;
              var address$1 = Ethers.utils.getAddress(address);
              return Promise.all([
                            syntheticTokenBalance(provider$1, config, marketIndex, isLong, address$1),
                            syntheticTokenPrice(provider$1, config, marketIndex, isLong)
                          ]).then(function (param) {
                          var balance = param[0];
                          return {
                                  paymentToken: balance.mul(param[1]),
                                  syntheticToken: balance
                                };
                        });
            });
}

function stakedPositions(side, ethAddress, param) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              var address;
              if (ethAddress !== undefined) {
                address = ethAddress;
              } else if (side.TAG === /* P */0) {
                console.log("No address found");
                address = "";
              } else {
                address = side._0.wallet.address;
              }
              var provider$1 = provider(side);
              var marketIndex = Ethers.BigNumber.from(side._0.marketIndex);
              var isLong = side._0.isLong;
              var address$1 = Ethers.utils.getAddress(address);
              return Promise.all([
                            stakedSyntheticTokenBalance(provider$1, config, marketIndex, isLong, address$1),
                            syntheticTokenPrice(provider$1, config, marketIndex, isLong)
                          ]).then(function (param) {
                          var balance = param[0];
                          return {
                                  paymentToken: balance.mul(param[1]),
                                  syntheticToken: balance
                                };
                        });
            });
}

function unsettledPositions(side, ethAddress) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(side))).then(function (config) {
              var address;
              if (ethAddress !== undefined) {
                address = ethAddress;
              } else if (side.TAG === /* P */0) {
                console.log("No address found");
                address = "";
              } else {
                address = side._0.wallet.address;
              }
              var provider$1 = provider(side);
              var marketIndex = Ethers.BigNumber.from(side._0.marketIndex);
              var isLong = side._0.isLong;
              var address$1 = Ethers.utils.getAddress(address);
              return updateIndex(provider$1, config, marketIndex, address$1).then(function (index) {
                            return Promise.all([
                                        syntheticTokenPriceSnapshot(provider$1, config, marketIndex, isLong, index),
                                        unsettledSynthBalance(provider$1, config, marketIndex, isLong, address$1)
                                      ]);
                          }).then(function (param) {
                          var balance = param[1];
                          return {
                                  paymentToken: balance.mul(param[0]),
                                  syntheticToken: balance
                                };
                        });
            });
}

function mint$1(side, amountPaymentToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (config) {
              return mint(side.wallet, config, Ethers.BigNumber.from(side.marketIndex), side.isLong, amountPaymentToken)(Float__Contracts.convertTxOptions(txOptions));
            });
}

function mintAndStake$1(side, amountPaymentToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (c) {
              return mintAndStake(side.wallet, c, Ethers.BigNumber.from(side.marketIndex), side.isLong, amountPaymentToken)(Float__Contracts.convertTxOptions(txOptions));
            });
}

function stake(side, amountSyntheticToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (c) {
              var wallet = side.wallet;
              var marketIndex = Ethers.BigNumber.from(side.marketIndex);
              var isLong = side.isLong;
              var txOptions$1 = Float__Contracts.convertTxOptions(txOptions);
              return syntheticTokenAddress(wallet.provider, c, marketIndex, isLong).then(function (address) {
                            return Promise.resolve(Float__Contracts.Synth.make(address, Float__Ethers.wrapWallet(wallet)));
                          }).then(function (synth) {
                          return synth.stake(amountSyntheticToken, txOptions$1);
                        });
            });
}

function unstake$1(side, amountSyntheticToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (c) {
              return unstake(side.wallet, c, Ethers.BigNumber.from(side.marketIndex), side.isLong, amountSyntheticToken)(Float__Contracts.convertTxOptions(txOptions));
            });
}

function redeem$1(side, amountSyntheticToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (c) {
              return redeem(side.wallet, c, Ethers.BigNumber.from(side.marketIndex), side.isLong, amountSyntheticToken)(Float__Contracts.convertTxOptions(txOptions));
            });
}

function shift$1(side, amountSyntheticToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (c) {
              return shift(side.wallet, c, Ethers.BigNumber.from(side.marketIndex), side.isLong, amountSyntheticToken)(Float__Contracts.convertTxOptions(txOptions));
            });
}

function shiftStake$1(side, amountSyntheticToken, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(side.wallet)).then(function (c) {
              return shiftStake(side.wallet, c, Ethers.BigNumber.from(side.marketIndex), side.isLong, amountSyntheticToken)(Float__Contracts.convertTxOptions(txOptions));
            });
}

var convert = Float__Contracts.convertTxOptions;

exports.min = min;
exports.max = max;
exports.div = div;
exports.mul = mul;
exports.add = add;
exports.sub = sub;
exports.fromInt = fromInt;
exports.fromFloat = fromFloat;
exports.toNumber = toNumber;
exports.toNumberFloat = toNumberFloat;
exports.tenToThe18 = tenToThe18;
exports.tenToThe14 = tenToThe14;
exports.convert = convert;
exports.wrapSideP = wrapSideP;
exports.wrapSideW = wrapSideW;
exports.WithProvider = WithProvider;
exports.WithWallet = WithWallet;
exports.makeUsingMarket = makeUsingMarket;
exports.syntheticTokenAddress = syntheticTokenAddress;
exports.syntheticTokenTotalSupply = syntheticTokenTotalSupply;
exports.syntheticTokenBalance = syntheticTokenBalance;
exports.stakedSyntheticTokenBalance = stakedSyntheticTokenBalance;
exports.marketSideValue = marketSideValue;
exports.updateIndex = updateIndex;
exports.unsettledSynthBalance = unsettledSynthBalance;
exports.marketSideUnconfirmedDeposits = marketSideUnconfirmedDeposits;
exports.marketSideUnconfirmedRedeems = marketSideUnconfirmedRedeems;
exports.marketSideUnconfirmedShifts = marketSideUnconfirmedShifts;
exports.syntheticTokenPriceSnapshot = syntheticTokenPriceSnapshot;
exports.marketSideValues = marketSideValues;
exports.syntheticToken = syntheticToken;
exports.name = name;
exports.poolValue = poolValue;
exports.syntheticTokenPrice = syntheticTokenPrice$1;
exports.exposure = exposure;
exports.unconfirmedExposure = unconfirmedExposure;
exports.fundingRateApr = fundingRateApr;
exports.positions = positions;
exports.stakedPositions = stakedPositions;
exports.unsettledPositions = unsettledPositions;
exports.mint = mint$1;
exports.mintAndStake = mintAndStake$1;
exports.stake = stake;
exports.unstake = unstake$1;
exports.redeem = redeem$1;
exports.shift = shift$1;
exports.shiftStake = shiftStake$1;
/* ethers Not a pure module */
