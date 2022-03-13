// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol"; // for testing accounts
import "../contracts/Ballot.sol";

contract BallotTest is Ballot {
    
    /// Define variables
    /*
     * acc[0] -> Chairperson, contract initiator
     * acc[1] -> Normal voting
     * acc[2] -> To delegate to acc[4]
     * acc[3] -> To chained delegate through acc[2] to acc[4]
     * acc[4] -> To vote with delegation
     * acc[5] -> To delegate to acc[4] post acc[4] voting
     * acc[startNR] -> To delegate without voting rights
     */
    uint accNum = 7; // Number of accounts to test with
    uint startNR = accNum - 1; // Starting index of testing accounts with no voting rights
    address[] public acc; // Array of accounts to test with
    address[] internal accWithRight; // Array of accounts to test with voting rights
    bytes32[] proposalNames = [bytes32("proposal1"), bytes32("proposal2")];

    /// Initiate variables
    function beforeAll() public {
        for (uint i = 0; i  < accNum; i++) {
            acc.push(TestsAccounts.getAccount(i));
        }
        for (uint i = 0; i < startNR; i++) {
            accWithRight.push(acc[i]);
        }
    }

    /// Construct Ballot
    constructor() Ballot(proposalNames){}

    /// Check if chairperson is initialized correctly
    function checkChairperson() public {
        Assert.equal(chairperson, acc[0], "chairperson should be acc[0]");
        Assert.ok(!voters[acc[0]].voted, "chairperson's voted status is incorrectly initalized");
        Assert.equal(voters[acc[0]].weight, 1, "chairperson's voting weight is incorrectly initalized");
        Assert.equal(voters[acc[0]].delegate, address(0), "chairperson's delegate address is incorrectly initalized");
        Assert.equal(voters[acc[0]].vote, 0, "chairperson's proposal index voted is incorrectly initalized");
    }
    
    /// Distribute rights to vote
    function testGiveRightToVote() public {
        Assert.equal(msg.sender, acc[0], "wrong sender in testGiveRightToVote");
        giveRightToVote(accWithRight);
        for (uint i = 1; i  < startNR; i++) {
            Assert.equal(voters[acc[i]].weight, 1, "voter's voting weight is incorrectly allocated");
            Assert.ok(!voters[acc[i]].voted, "voter's voted status is incorrectly initalized");
            Assert.equal(voters[acc[i]].delegate, address(0), "voter's delegate address is incorrectly initalized");
            Assert.equal(voters[acc[i]].vote, 0, "voter's proposal index voted is incorrectly initalized");
        }
    }

    /// Test normal vote
    /// #sender: account-1
    function testVote() public {
        Assert.equal(msg.sender, acc[1], "wrong sender in testVote");
        vote(0);
        Assert.ok(voters[acc[1]].voted, "sender's voted status is not updated");
        Assert.equal(voters[acc[1]].vote, 0, "sender's proposal index voted is not updated");
        Assert.equal(proposals[0].voteCount, 1, "proposal's vote count is not incremented");
    }

    /// Test delegate to delegate yet to vote
    /// #sender: account-2
    function testDelegate() public {
        Assert.equal(msg.sender, acc[2], "wrong sender in testDelegate");
        delegate(acc[4]);
        Assert.ok(voters[acc[2]].voted, "sender's voted status is not updated");
        Assert.equal(voters[acc[2]].delegate, acc[4], "sender's delegate address is not updated");
        Assert.equal(voters[acc[4]].weight, 2, "delegate's weight is not incremented");
    }

    /// Test chained delegate through voter already delegated to delegate yet to vote
    /// #sender: account-3
    function testChainedDelegate() public {
        Assert.equal(msg.sender, acc[3], "wrong sender in testChainedDelegate");
        delegate(acc[2]);
        Assert.ok(voters[acc[3]].voted, "sender's voted status is not updated");
        Assert.equal(voters[acc[3]].delegate, acc[4], "sender's delegate address is not updated");
        Assert.equal(voters[acc[4]].weight, 3, "delegate's weight is not incremented");
    }

    /// Test delegate vote
    /// #sender: account-4
    function testDelegateVote() public {
        Assert.equal(msg.sender, acc[4], "wrong sender in testDelegateVote");
        vote(1);
        Assert.ok(voters[acc[4]].voted, "sender's voted status is not updated");
        Assert.equal(voters[acc[4]].vote, 1, "sender's proposal index voted is not updated");
        Assert.equal(proposals[1].voteCount, 3, "proposal's vote count is not incremented");
    }

    /// Test delegate to delegate already voted
    /// #sender: account-5
    function testPostVoteDelegate() public {
        Assert.equal(msg.sender, acc[5], "wrong sender in testPostVoteDelegate");
        delegate(acc[4]);
        Assert.ok(voters[acc[5]].voted, "sender's voted status is not updated");
        Assert.equal(voters[acc[5]].delegate, acc[4], "sender's delegate address is not updated");
        Assert.equal(voters[acc[4]].weight, 3, "delegate's weight is incorrectly updated");
        Assert.equal(proposals[1].voteCount, 4, "proposal's vote count is not incremented");
    }

    /// Check if winning proposal is correct
    function checkWinningProposal() public {
        Assert.equal(winningProposal(), 1, "proposal at index 1 should be the winning proposal");
        Assert.equal(winnerName(), bytes32("proposal2"), "proposal2 should be the winner name");
    }

    /// Test delegate without voting rights
    /// #sender: account-6
    function testNoRightDelegate() public {
        Assert.equal(msg.sender, acc[startNR], "wrong sender in testNoRightDelegate");
        delegate(acc[4]);
        Assert.ok(voters[acc[startNR]].voted, "sender's voted status is not updated");
        Assert.equal(voters[acc[startNR]].delegate, acc[4], "sender's delegate address is not updated");
        Assert.equal(voters[acc[4]].weight, 3, "delegate's weight is incorrectly updated");
        Assert.equal(proposals[1].voteCount, 4, "proposal's vote count is not incremented");
    }
}

/**
 * Unexpected behaviors:
 * 1. [Ballot.sol] Delegate with new account without voting rights passes
 * 2. [Ballot_test.sol] Method to try-catch with designated msg.sender yet to be found: https://ethereum.stackexchange.com/questions/121773/unexpected-catch-error-behavior
 */