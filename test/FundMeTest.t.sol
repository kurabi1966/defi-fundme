// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
// Test net SIPOLIA
// forge test --fork-url $SEPOLIA_RPC_URL

contract FundeMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinFundIsFiveDollar() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedAddressToAmountFunded() public {
        fundMe.fund{value: 1e18}();

        assertEq(fundMe.getAddressToAmountFunded(address(this)), 1e18);
    }

    function testFundUpdatesFundersLength() public {
        fundMe.fund{value: 1e18}();

        assertEq(fundMe.getFundersCount(), 1);
    }

    function testSuccessWithdraw() public {
      fundMe.fund{value: 1e18}();
      
    }
}
