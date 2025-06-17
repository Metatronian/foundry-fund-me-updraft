//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    using PriceConverter for uint256;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1000 ether;
    uint256 constant GAS_PRICE = 1;

    address USER = makeAddr("user");
    address USER_TWO = makeAddr("user 2");

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(USER, STARTING_BALANCE);
        deal(USER_TWO, STARTING_BALANCE);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        // assert (this tx fails/reverts)
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //The next TX will be send by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.prank(USER_TWO);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
        address funderTwo = fundMe.getFunder(1);
        assertEq(funderTwo, USER_TWO);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange (set up the context for it to work)
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act (do the actual action you are testing)
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert (check that the outcomes are the expected ones)
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        /*    uint256 gasStart = gasleft(); //we always send a bit more gas than needed just in case
              vm.txGasPrice(GAS_PRICE);*/
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        /*    uint256 gasEnd = gasleft();
              uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
              console.log("Gas used: ", gasUsed);*/

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        _;
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(
            "Minimum ETH is: ",
            fundMe.MINIMUM_USD().getMinimumEthAmount(fundMe.s_priceFeed())
        );
    }

    function testOwnerIsMsgSender() public view {
        console.log("Owner is: ", fundMe.getOwner());
        //the actual msg.sender is the address of the contract,
        //because we are calling the constructor from the test contract
        console.log("Msg.sender is: ", msg.sender);
        //the msg.sender address will be an address from the console
        //because we are calling the test from the console
        assertEq(fundMe.getOwner(), msg.sender);
        //so to test the owner, we need to use the address
        //of the test contract
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log("current network is ", address(fundMe.s_priceFeed()));
        console.log("version is ", version);
        assertEq(version, 4);
    }
}
