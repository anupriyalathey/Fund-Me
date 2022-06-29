// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    //to get price in usd
    function getPrice() internal view returns (uint256) {
        //ABI
        //Address - 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e (Rinkeby ETH/USD)
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // ETH/USD rate in 18 digit
        return uint256(price * 1e10); //Typecasting
    }

    function getConversionRate(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        // the actual ETH/USD conversion rate, after adjusting the extra 0s
        return ethAmountInUsd;
    }
}
