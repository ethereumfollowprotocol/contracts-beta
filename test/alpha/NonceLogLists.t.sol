// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../../src/alpha/ArrayLists.sol";
import {NonceLogLists} from "../../src/alpha/NonceLogLists.sol";
import {ListRecord} from "../../src/alpha/ListRecord.sol";

contract NonceLogListsTest is Test {
    NonceLogLists public nonceLogLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
    address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
    address ADDRESS_3 = 0x0000000000000000000000000000000000789AbC;

    function setUp() public {
        nonceLogLists = new NonceLogLists();
    }

    function test_ListManagerDefaultsToZeroAddress() public {
        address listManager = nonceLogLists.getListManager(NONCE);
        assertEq(listManager, address(0));
    }

    function test_CanClaimListManager() public {
        nonceLogLists.claimListManager(NONCE);
        address listManagerAfter = nonceLogLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));
    }

    function test_CanClaimListManagerAndSetManager() public {
        nonceLogLists.claimListManager(NONCE);
        address listManagerAfter = nonceLogLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));

        nonceLogLists.setListManager(NONCE, address(123));
        address listManagerAfter2 = nonceLogLists.getListManager(NONCE);
        assertEq(listManagerAfter2, address(123));
    }

    function test_CanClaimThenAppendRecord() public {
        nonceLogLists.claimListManager(NONCE);
        nonceLogLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_RevertIf_NotListManager() public {
        vm.expectRevert("Not manager");
        nonceLogLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_CanClaimThenDeleteRecord() public {
        nonceLogLists.claimListManager(NONCE);

        nonceLogLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
        bytes32 hash = keccak256(abi.encode(VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1)));

        nonceLogLists.deleteRecord(NONCE, hash);
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}