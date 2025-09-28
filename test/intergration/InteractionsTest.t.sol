// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntergrationsTest is
    Test //这个函数用来测试Interactions脚本
{
    address USER = makeAddr("user");
    //makeAddr是forge-std自带的一个函数，可以生成一个地址,用这个地址调用fund函数进行测试
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    FundMe fundMe;

    function setUp() external {   // 注意大写的 U
        DeployFundMe deploy = new DeployFundMe(); //DeployFundMe合约实例化
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
        console.log("FundMe address:", address(fundMe));
    } //部署FundMe合约，并给USER地址转账10ETH

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}


//这个合约实现了集成测试，测试了Interactions脚本中的捐款和提现功能