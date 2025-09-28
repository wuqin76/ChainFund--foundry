// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    //makeAddr是forge-std自带的一个函数，可以生成一个地址,用这个地址调用fund函数进行测试
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() public {
        //fundMe = new FundMe();
        DeployFundMe deployer = new DeployFundMe(); //DeployFundMe合约实例化
        fundMe = deployer.run(); //fundMe合约实例化,会返回一个FundMe合约地址
        //这里就是通过DeployFundMe脚本先部署合约，再拿到合约地址，进行测试
        vm.deal(USER, STARTING_BALANCE); //给USER地址转账10ETH
    }

    function testMinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log("Minimum USD:", fundMe.MINIMUM_USD());
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
        console.log("Owner:", fundMe.getOwner());
        console.log("This contract:", address(this));
    }
    function testPriceFeedVersionIsAccurate() public view {
        uint version = fundMe.getVersion();
        console.log("Price Feed Version:", version);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //让下一个调用者变成USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        //uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
        //这个是错误的因为msg.sender是测试合约的地址
        //所以我们可以使用prank来模拟USER地址调用，让调用者变成USER
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); //让下一个调用者变成USER
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); //让下一个调用者变成USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOnlyOwnerCanWithdrawCheaper() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdrawCheaper();
    }

    function testWithdrawWithASingleFunder() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //act
        vm.prank(fundMe.getOwner()); //让下一个调用者变成owner
        fundMe.withdraw();
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank(address(i)); // 让下一个调用者变成 address(i)
            //fundMe.fund{value: SEND_VALUE}(); // 调用 fund 函数
            hoax(address(i), SEND_VALUE); // 让下一个调用者变成 address(i) 并且给他转账 SEND_VALUE
            fundMe.fund{value: SEND_VALUE}(); // 调用 fund 函数
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //act

        vm.prank(fundMe.getOwner()); //让下一个调用者变成owner
        fundMe.withdraw();
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}

// forge test -vv  （这里的v是表示输出的详细等级）
// forge coverage
// forge test --gas-report
//测试匹配名字的函数forge test --match-test testPriceFeedVersionIsAccurate -vvv --fork-url $MAINNET_RPC_URL
//
