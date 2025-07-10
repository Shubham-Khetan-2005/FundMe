//SPDX-Lisence-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    // This function test that the user can fund the contract
    function testUserCanFundInteraction() public {
        FundFundMe fundTheFundMe = new FundFundMe();
        fundTheFundMe.fundTheFundMe(address(fundMe));

        WithdrawFundMe withdrawTheFundMe = new WithdrawFundMe();
        withdrawTheFundMe.withdrawTheFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
