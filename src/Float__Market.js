// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Ethers = require("ethers");
var Caml_array = require("rescript/lib/js/caml_array.js");
var Float__Util = require("./Float__Util.js");
var Float__Ethers = require("./Float__Ethers.js");
var Float__Contracts = require("./Float__Contracts.js");
var Float__MarketSide = require("./Float__MarketSide.js");
var Float__Market__shared = require("./Float__Market__shared.js");

function div(prim0, prim1) {
  return prim0.div(prim1);
}

function fromInt(prim) {
  return Ethers.BigNumber.from(prim);
}

function toNumber(prim) {
  return prim.toNumber();
}

var tenToThe18 = Float__Ethers.BigNumber.tenToThe18;

function makeUnwrapped(provider, marketIndex) {
  return {
          provider: provider,
          marketIndex: marketIndex
        };
}

function make(provider, marketIndex) {
  return Float__Market__shared.wrapMarketP({
              provider: provider,
              marketIndex: marketIndex
            });
}

function makeReverseCurry(marketIndex, provider) {
  return Float__Market__shared.wrapMarketP({
              provider: provider,
              marketIndex: marketIndex
            });
}

function makeDefault(chainId) {
  var partial_arg = Float__Util.makeDefaultProvider(Float__Util.getChainConfigUsingId(chainId));
  return function (param) {
    return Float__Market__shared.wrapMarketP({
                provider: partial_arg,
                marketIndex: param
              });
  };
}

function makeDefaultUnwrapped(chainId) {
  var partial_arg = Float__Util.makeDefaultProvider(Float__Util.getChainConfigUsingId(chainId));
  return function (param) {
    return {
            provider: partial_arg,
            marketIndex: param
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

function makeUnwrapped$1(w, marketIndex) {
  return {
          wallet: w,
          marketIndex: marketIndex
        };
}

function make$1(w, marketIndex) {
  return Float__Market__shared.wrapMarketW({
              wallet: w,
              marketIndex: marketIndex
            });
}

var WithWallet = {
  makeUnwrapped: makeUnwrapped$1,
  make: make$1
};

function makeUsingChain(chain, marketIndex) {
  if (chain.TAG === /* P */0) {
    return Float__Market__shared.wrapMarketP({
                provider: chain._0.provider,
                marketIndex: marketIndex
              });
  } else {
    return Float__Market__shared.wrapMarketW({
                wallet: chain._0.wallet,
                marketIndex: marketIndex
              });
  }
}

function provider(side) {
  if (side.TAG === /* P */0) {
    return side._0.provider;
  } else {
    return side._0.wallet.provider;
  }
}

function longSide(param, param$1) {
  return Float__MarketSide.WithProvider.makeReverseCurry(true, param, param$1);
}

function shortSide(param, param$1) {
  return Float__MarketSide.WithProvider.makeReverseCurry(false, param, param$1);
}

function claimFloatCustomFor(wallet, config, marketIndexes, address) {
  var partial_arg = Float__Util.makeStakerContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg.claimFloatCustomFor(marketIndexes, address, param);
  };
}

function settleOutstandingActions(wallet, config, marketIndex, address) {
  var partial_arg = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg.executeOutstandingNextPriceSettlementsUser(address, marketIndex, param);
  };
}

function updateSystemState(wallet, config, marketIndex) {
  var partial_arg = Float__Util.makeLongShortContract(Float__Ethers.wrapWallet(wallet), config);
  return function (param) {
    return partial_arg.updateSystemState(marketIndex, param);
  };
}

function contracts(market) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(market))).then(function (config) {
              return {
                      longToken: Caml_array.get(config.markets, market._0.marketIndex).longToken,
                      shortToken: Caml_array.get(config.markets, market._0.marketIndex).shortToken,
                      yieldManager: Caml_array.get(config.markets, market._0.marketIndex).yieldManager,
                      paymentToken: Caml_array.get(config.markets, market._0.marketIndex).paymentToken,
                      oracleManager: Caml_array.get(config.markets, market._0.marketIndex).oracleManager
                    };
            });
}

function leverage(market) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(market))).then(function (config) {
              var provider$1 = provider(market);
              var marketIndex = Ethers.BigNumber.from(market._0.marketIndex);
              return Float__Util.makeLongShortContract(Float__Ethers.wrapProvider(provider$1), config).marketLeverage_e18(marketIndex);
            });
}

function fundingRateMultiplier(market) {
  return Float__Util.getChainConfig(Float__Ethers.wrapProvider(provider(market))).then(function (config) {
              return Float__Market__shared.fundingRateMultiplier(provider(market), config, Ethers.BigNumber.from(market._0.marketIndex));
            });
}

function syntheticTokenPrices(market) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.syntheticTokenPrice(longSide(marketIndex, provider$1)),
                Float__MarketSide.syntheticTokenPrice(shortSide(marketIndex, provider$1))
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function exposures(market) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.exposure(longSide(marketIndex, provider$1)),
                Float__MarketSide.exposure(shortSide(marketIndex, provider$1))
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function unconfirmedExposures(market) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.unconfirmedExposure(longSide(marketIndex, provider$1)),
                Float__MarketSide.unconfirmedExposure(shortSide(marketIndex, provider$1))
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function fundingRateAprs(market) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.fundingRateApr(longSide(marketIndex, provider$1)),
                Float__MarketSide.fundingRateApr(shortSide(marketIndex, provider$1))
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function positions(market, ethAddress) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.positions(longSide(marketIndex, provider$1), undefined, ethAddress),
                Float__MarketSide.positions(shortSide(marketIndex, provider$1), undefined, ethAddress)
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function stakedPositions(market, ethAddress) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.stakedPositions(longSide(marketIndex, provider$1), undefined, ethAddress),
                Float__MarketSide.stakedPositions(shortSide(marketIndex, provider$1), undefined, ethAddress)
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function unsettledPositions(market, ethAddress) {
  var provider$1 = provider(market);
  var marketIndex = market._0.marketIndex;
  return Promise.all([
                Float__MarketSide.unsettledPositions(longSide(marketIndex, provider$1), ethAddress),
                Float__MarketSide.unsettledPositions(shortSide(marketIndex, provider$1), ethAddress)
              ]).then(function (param) {
              return {
                      long: param[0],
                      short: param[1]
                    };
            });
}

function claimFloatCustom(market, ethAddress, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(market.wallet)).then(function (config) {
              var address = ethAddress !== undefined ? ethAddress : market.wallet.address;
              return claimFloatCustomFor(market.wallet, config, [Ethers.BigNumber.from(market.marketIndex)], Ethers.utils.getAddress(address))(Float__Contracts.convertTxOptions(txOptions));
            });
}

function settleOutstandingActions$1(market, ethAddress, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(market.wallet)).then(function (config) {
              var address = ethAddress !== undefined ? ethAddress : market.wallet.address;
              return settleOutstandingActions(market.wallet, config, Ethers.BigNumber.from(market.marketIndex), Ethers.utils.getAddress(address))(Float__Contracts.convertTxOptions(txOptions));
            });
}

function updateSystemState$1(market, txOptions) {
  return Float__Util.getChainConfig(Float__Ethers.wrapWallet(market.wallet)).then(function (config) {
              return updateSystemState(market.wallet, config, Ethers.BigNumber.from(market.marketIndex))(Float__Contracts.convertTxOptions(txOptions));
            });
}

var convert = Float__Contracts.convertTxOptions;

exports.div = div;
exports.fromInt = fromInt;
exports.toNumber = toNumber;
exports.tenToThe18 = tenToThe18;
exports.convert = convert;
exports.WithProvider = WithProvider;
exports.WithWallet = WithWallet;
exports.makeUsingChain = makeUsingChain;
exports.claimFloatCustomFor = claimFloatCustomFor;
exports.contracts = contracts;
exports.leverage = leverage;
exports.fundingRateMultiplier = fundingRateMultiplier;
exports.syntheticTokenPrices = syntheticTokenPrices;
exports.exposures = exposures;
exports.unconfirmedExposures = unconfirmedExposures;
exports.fundingRateAprs = fundingRateAprs;
exports.positions = positions;
exports.stakedPositions = stakedPositions;
exports.unsettledPositions = unsettledPositions;
exports.claimFloatCustom = claimFloatCustom;
exports.settleOutstandingActions = settleOutstandingActions$1;
exports.updateSystemState = updateSystemState$1;
/* ethers Not a pure module */
