// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConvertor.sol";

error NotOwner();

contract FundMe {
    using PriceConvertor for uint256;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address public i_owner; //immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        //want to be able to set a min fund amount in USD
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset array
        funders = new address[](0);

        //transfer
        // payable ( msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        return priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner, "Sender is not owner!");
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    //What happens when someone sends this contract ETH without calling the fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
