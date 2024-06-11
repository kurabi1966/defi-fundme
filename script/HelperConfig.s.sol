// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
// 1. Deploy mocks when we are in an anvil local chain
// 2. Keep track of contract address acrose deferent chains
// MainNet: ETH/USD: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
// Seploia Test net: ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306

contract HelperConfig is Script {
    // if we are on anvil local chain, we deploy mocks
    // if we are on seploia we return 0x694AA1769357215DE4FAC081bf1f309aDC325306
    // if we are on the main net we return: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419

    // How to know what is the current chain?
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    int256 private constant ETH_USD_MOCK_PRICE = 3800e8;
    uint8 private constant ETH_USD_MOCK_DECIMALS = 8;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant MAINNET_CHAIN_ID = 1;
    uint256 private constant ZKEVM_CHAIN_ID = 1101;

    constructor() {
        // check what is the current chain, then assign
        if (block.chainid == MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainnetEthConfig();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == ZKEVM_CHAIN_ID) {
            activeNetworkConfig = getPolygonZKEvmEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() private pure returns (NetworkConfig memory network) {
        network = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getMainnetEthConfig() private pure returns (NetworkConfig memory network) {
        network = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }

    function getPolygonZKEvmEthConfig() private pure returns (NetworkConfig memory network) {
        network = NetworkConfig({priceFeed: 0x97d9F9A00dEE0004BE8ca0A8fa374d486567eE2D});
    }

    function getOrCreateAnvilEthConfig() private returns (NetworkConfig memory network) {
        // We have to deploy a mock of a priceFeed in our local anvil, then we need
        // to return a network object the contains the address of the priceFeed contract
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(ETH_USD_MOCK_DECIMALS, ETH_USD_MOCK_PRICE);

        vm.stopBroadcast();
        network = NetworkConfig({priceFeed: address(mockV3Aggregator)});
    }
}
