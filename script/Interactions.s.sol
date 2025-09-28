//SPDX-License-Identifier: MIT

//fund
//withdraw

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol"; //帮助铸造厂跟踪最近部署的合同版本

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); //调用fund函数，发送0.01ETH
        console.log("Funded FundMe with %s", SEND_VALUE);
    }  //这个函数可以用来调用了FundMe合约的fund函数，发送了0.01ETH

    function run() external {
        //获得最近部署的地址
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );  //通过DevOpsTools获取最近部署的FundMe合约地址
        vm.startBroadcast();  //
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}  //这个函数实现了给最近部署的FundMe合约捐款0.01ETH

contract WithdrawFundMe is Script {  //提款合约
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrew FundMe");
    }  //这个函数可以用来调用了FundMe合约的withdraw函数，提现所有ETH

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        WithdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }   //这个函数实现了从最近部署的FundMe合约提现所有ETH
}
//这个合约实现了两个脚本，一个是给FundMe合约捐款，另一个是从FundMe合约提现