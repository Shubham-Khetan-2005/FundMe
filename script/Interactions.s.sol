//SPDX-Lisence-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    // Funds the most recent deployment
    function fundTheFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    // Runs the most recent deployment
    function run() external {
        address mostRecent = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundTheFundMe(mostRecent);
    }
}

contract WithdrawFundMe is Script {
    function withdrawTheFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecent = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawTheFundMe(mostRecent);
    }
}
