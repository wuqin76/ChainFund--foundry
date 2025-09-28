// SPDX-License-Identifier: MIT

//在本地部署区块链
//跨不同的链跟踪合约地址

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_ANSWER = 2000e18;

    constructor() {
        if (block.chainid == 11155111) {
            //sepolia
            activeNetworkConfig = getSepoliaEthUsdPriceFeed();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthUsdPriceFeed();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthUsdPriceFeed()
        public
        pure //表示函数不会读取或修改区块链上的状态
        returns (
            NetworkConfig memory
        )
    {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthUsdPriceFeed()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast(); //启动广播模式，表示接下来的操作会被视为链上交易，并且会使用您提供的私钥（通常是测试账户的私钥）来签名和发送交易。
        //部署mock price feed
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
