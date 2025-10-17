// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntergrationsTest is Test {
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
        console.log("FundMe address:", address(fundMe));
    }

    function testUserCanFundInteractions() public {
        // 创建 FundFundMe 脚本合约
        FundFundMe fundFundMe = new FundFundMe();

        // 给 FundFundMe 合约分配 ETH（它需要 ETH 来调用 fund）
        vm.deal(address(fundFundMe), 1 ether);

        // 捐款
        fundFundMe.fundFundMe(address(fundMe));

        // 获取合约 owner
        address fundMeOwner = fundMe.getOwner();

        // 模拟 owner 直接调用 withdraw
        vm.prank(fundMeOwner);
        fundMe.withdraw();

        // 验证余额为 0
        assertEq(address(fundMe).balance, 0);
    }
}
