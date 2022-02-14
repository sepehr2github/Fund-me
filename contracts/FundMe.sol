// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        // $2
        uint256 minimumUSD = 2 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH! at least 2 dollars!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // what the Eth -> USD conrversion rate
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }  

    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        
      (,int256 answer,,,) = priceFeed.latestRoundData();

      return uint256(answer * 10000000000);
    }

    function getDecimals() public view returns(uint8){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.decimals();
    }

    // 1000000000
    function getConversionRate(uint ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount);
        return ethAmountInUsd / 1000000000000000000;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You're not the owner of this contract!");
        _;
    }

    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);

        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}