//SPDX-Lisence-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testEnoughUSD() public {
        vm.expectRevert(); // We expect the next line to fail
        fundMe.fund();
    }

    function testFundUpdatesFundDataStructures() public funded{
        assertEq(fundMe.getFunderAmount(USER), SEND_VALUE);
        assertEq(fundMe.getFunders(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);     // The next txn will be sent by user -- to avoid confuison between msg.sender and address(this)
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawWithAMultipleFunder() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startIndex = 1;

        for(uint160 i = startIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);     // hoax = vm.prank + vm.deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }
}
