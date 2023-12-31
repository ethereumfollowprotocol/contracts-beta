// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {EFPListRecords} from "../src/EFPListRecords.sol";

contract EFPListRecordsTest is Test {
    EFPListRecords public listRecords;
    uint8 constant LIST_OP_VERSION = 1;
    uint8 constant LIST_OP_TYPE_ADD_RECORD = 1;
    uint8 constant LIST_OP_TYPE_REMOVE_RECORD = 2;
    uint8 constant LIST_OP_TYPE_ADD_TAG = 3;
    uint8 constant LIST_OP_TYPE_REMOVE_TAG = 4;
    uint8 constant LIST_RECORD_VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
    address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
    address ADDRESS_3 = 0x0000000000000000000000000000000000789AbC;
    uint256 constant NONCE = 0;

    function setUp() public {
        listRecords = new EFPListRecords();
    }

    function test_CanClaimListManager() public {
        vm.prank(ADDRESS_1);
        listRecords.claimListManager(NONCE);

        assertEq(listRecords.getListManager(NONCE), ADDRESS_1, "Manager1 should be the manager of list 1");
    }

    function test_CanSetListManager() public {
        vm.prank(ADDRESS_1);
        listRecords.claimListManager(NONCE);

        vm.prank(ADDRESS_1);
        listRecords.setListManager(NONCE, ADDRESS_2);

        assertEq(listRecords.getListManager(NONCE), ADDRESS_2, "Manager2 should now be the manager of list 1");
    }

    function test_CanApplyListOpToAddRecord() public {
        helper_CanApplyListOp(LIST_OP_TYPE_ADD_RECORD);
    }

    function test_CanApplyListOpToRemoveRecord() public {
        helper_CanApplyListOp(LIST_OP_TYPE_REMOVE_RECORD);
    }

    function test_CanApplyListOpToAddTag() public {
        helper_CanApplyListOp(LIST_OP_TYPE_ADD_TAG);
    }

    function test_CanApplyListOpToRemoveTag() public {
        helper_CanApplyListOp(LIST_OP_TYPE_REMOVE_TAG);
    }

    function helper_CanApplyListOp(uint8 opType) internal {
        assertEq(listRecords.getListOpCount(NONCE), 0);

        // listRecords.claimListManager(NONCE);

        bytes memory listOp = encodeListOp(opType);
        listRecords.applyListOp(NONCE, listOp);

        assertEq(listRecords.getListOpCount(NONCE), 1);
        assertBytesEqual(listRecords.getListOp(NONCE, 0), listOp);
    }

    function test_CanApplyMultipleListOpsAtOnce() public {
        assertEq(listRecords.getListOpCount(NONCE), 0);

        // listRecords.claimListManager(NONCE);

        bytes[] memory listOps = new bytes[](2);
        listOps[0] = encodeListOp(LIST_OP_TYPE_ADD_RECORD);
        listOps[1] = encodeListOp(LIST_OP_TYPE_REMOVE_RECORD);
        listRecords.applyListOps(NONCE, listOps);

        assertEq(listRecords.getListOpCount(NONCE), 2);
        assertBytesEqual(listRecords.getListOp(NONCE, 0), listOps[0]);
        assertBytesEqual(listRecords.getListOp(NONCE, 1), listOps[1]);
    }

    function encodeListOp(uint8 opType) internal view returns (bytes memory) {
        bytes memory result = abi.encodePacked(
            LIST_OP_VERSION, // Version for ListOp
            opType, // Operation type for ListOp (Add Record)
            LIST_RECORD_VERSION, // Version for ListRecord
            LIST_RECORD_TYPE_RAW_ADDRESS, // Record type for ListRecord (Raw Address)
            ADDRESS_1 // Raw address (20 bytes)
        );
        if (opType == LIST_OP_TYPE_ADD_TAG || opType == LIST_OP_TYPE_REMOVE_TAG) {
            result = abi.encodePacked(result, "tag");
        }
        return result;
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint256 i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
