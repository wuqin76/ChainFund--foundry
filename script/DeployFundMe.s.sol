//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {   //部署FundMe合约
    HelperConfig helperConfig = new HelperConfig();  //HelperConfig合约实例化
    address public ethUsdpriceFeed = helperConfig.activeNetworkConfig();

    function run() external returns (FundMe) { 
        vm.startBroadcast();
        //vm 是 Foundry 提供的虚拟机工具，用于模拟链上操作。
        //startBroadcast 表示开始广播交易，之后的操作会被视为链上交易。
        FundMe fundMe = new FundMe(ethUsdpriceFeed);
        // 使用 new 关键字部署 FundMe 合约。
        // 部署完成后，FundMe 合约的实例会被创建并部署到链上。
        vm.stopBroadcast();
        // 停止广播交易，结束链上操作的模拟。
        return fundMe;
    }
}

//forge script script/DeployFundMe.s.sol 运行脚本
