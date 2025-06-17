//SPDX-License-Identifier: MIT
/*
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/InteractionsMIO.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1000 ether;
    uint256 constant GAS_PRICE = 1;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(USER, STARTING_BALANCE);
        console.log("USER balance before test: ", address(USER).balance);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMeContract = new FundFundMe();
        vm.prank(USER);
        fundFundMeContract.fundFundMe(address(fundMe));
        console.log("USER balance AFTER test: ", address(USER).balance);

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
}
*/