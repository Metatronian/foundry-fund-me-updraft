// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Why is this a library and not abstract?
// Why not an interface?
library PriceConverter {
    // We could make this public, but then we'd have to deploy it
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Sepolia ETH / USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(answer * 1e10);

        //esto me va el valor de 1ETH en dolares con 8 digitos, ejemplo $1,000.000.00
        //despues lo multiplicamos para agregarle 10 ceros mas y ponerlo en modo crypto, wei, $1,000.000.000.000.000.000
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        //llame primero la funcion anterior y obtengo el valro de ETH en USD
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        //ahora multiplique el valor de ETH por la cantidad de ETh que envie
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function getMinimumEthAmount(
        uint256 usdAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 requiredEth = (usdAmount * 1e18) / ethPrice;
        return requiredEth;
    }
}
