const Voting = artifacts.require("./Voting.sol");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract('Voting', accounts => {
    let [owner, second, third] = accounts;

    let votingInstance;

    describe("test complete", function () {

        beforeEach(async function () {
            votingInstance = await Voting.new({from : owner});
        });

        it("[Add Voter] should store voter in mapping", async () => {
            await votingInstance.addVoter(second, { from: owner });
            await votingInstance.addVoter(third, { from: owner });
            
            const storedData = await votingInstance.getVoter(second, { from: third });
            
            expect(storedData.isRegistered).to.equal(true);
        });

        it("[Add Proposal] should store proposal in array", async () => {
            const _proposal = "Proposal 1";
            await votingInstance.addVoter(second, { from: owner });
            await votingInstance.startProposalsRegistering({ from: owner });
            await votingInstance.addProposal(_proposal, { from: second });
            const storedData = await votingInstance.getOneProposal(1, { from: second });
            expect(storedData.description).to.equal(_proposal);
        });

        it("[Start Proposals Registering] should change workflow status to ProposalsRegistrationStarted", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            expect(votingInstance.workflowStatus).to.equal("ProposalsRegistrationStarted");
        });
    });

    describe("tests des event, du require, de revert", function () {

        beforeEach(async function () {
            votingInstance = await Voting.new({from : owner});
        });

        it("[Add Voter] should revert: registration is not open yet", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            await expectRevert(votingInstance.addVoter(second, {from:owner}), 'Voters registration is not open yet');
        });

        it("[Add Voter] should revert: voter already registred", async () => {
            await votingInstance.addVoter(second, { from: owner });
            await expectRevert(votingInstance.addVoter(second, {from:owner}), 'Already registered');
        });

        it("[Add Voter] should add voter, get event Voter Registered ", async () => {
            const findEvent = await votingInstance.addVoter(second, { from: owner });
            await votingInstance.addVoter(third, { from: owner });
            expectEvent(findEvent, "VoterRegistered" ,{voterAddress: second});
        });

        it("[Add Proposal] should revert when non voter add proposal", async () => {
            const _proposal = "Proposal 1";
            await votingInstance.startProposalsRegistering({ from: owner });
            await expectRevert(votingInstance.addProposal(_proposal, { from: second }), 'You are not a voter');
        });

        it("[Add Proposal] should revert when proposals are not allowed yet", async () => {
            const _proposal = "Proposal 1";
            await votingInstance.addVoter(second, { from: owner });
            await expectRevert(votingInstance.addProposal(_proposal, { from: second }), 'Proposals are not allowed yet');
        });

        it("[Add Proposal] should add voter, get event Proposal Registered ", async () => {
            const _proposal = "Proposal 1";
            await votingInstance.addVoter(second, { from: owner });
            await votingInstance.startProposalsRegistering({ from: owner });
            const findEvent = await votingInstance.addProposal(_proposal, { from: second });
            expectEvent(findEvent, "ProposalRegistered" ,{proposalId: new BN(1)});
        });

        it("[Start Proposals Registering] should send WorkflowStatusChange event", async () => {
            const findEvent = await votingInstance.startProposalsRegistering({ from: owner });
            expectEvent(findEvent, "WorkflowStatusChange");
        });
    });
});