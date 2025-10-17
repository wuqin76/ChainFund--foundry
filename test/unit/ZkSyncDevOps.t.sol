//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract ZkSyncDevOps is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    // Remove the `skipZkSync`, then run `forge test --mt testZkSyncChainFails --zksync` and this will fail!
    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));

        bool success;
        assembly {
            success := call(gas(), ripemd, 0, 0, 0, 0, 0)
        }
        assert(success);
    }

    // You'll need `ffi=true` in your foundry.toml to run this test
    // // Remove the `onlyVanillaFoundry`, then run `foundryup-zksync` and then
    // // `forge test --mt testZkSyncFoundryFails --zksync`
    // // and this will fail!
    // function testZkSyncFoundryFails() public onlyVanillaFoundry {
    //     bool exists = vm.keyExistsJson('{"hi": "true"}', ".hi");
    //     assert(exists);
    // }
}



//skipZkSync跳过ZkSync链测试
//onlyVanillaFoundry只在原生Foundry环境中运行测试
//onlyZkSync只在ZkSync环境中运行测试
//skipVanillaFoundry跳过原生Foundry环境测试
//有些测试只能在ZkSync链上运行，有些只能在原生Foundry环境中运行
//这些修饰符帮助我们控制测试的运行环境