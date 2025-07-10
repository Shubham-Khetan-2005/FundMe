//SPDX-Lisence-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on local Anvil, we deploy mock smart contracts
    // Otherwise Grab existing address from live network

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return config;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (address(activeNetworkConfig.priceFeed) != address(0)) {
            return activeNetworkConfig;
        }
        //Deploy Mock
        // return mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return config;
    }
}
