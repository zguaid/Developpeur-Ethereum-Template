// Voting.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Voting is Ownable {
    mapping(address => Voter) private voters;
    address[] public addresses;

    Proposal[] private proposals;

    Session[] public sessions;

    uint256 public time_now;
    uint256 public winningProposalId;
    uint256 public currentProposalSessionId;
    WorkflowStatus public currentSessionStatus;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        bool hasProposed;
        uint256 votedProposalId;
    }

    struct Proposal {
        uint256 sessionId;
        address proposerAddress;
        string description;
        uint256 voteCount;
    }

    struct Session {
        uint256 startTime;
        uint256 endTime;
        string winnerProposalName;
        address winningProposerAddress;
        uint256 nbVotes;
        uint256 totalVotes;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint256 sessionId, uint256 proposalId, address voterAddress, string proposal);
    event Voted(address voterAddress,uint256 sessionId, uint256 proposalId);

    constructor() {
        currentProposalSessionId = 0;
        currentSessionStatus = WorkflowStatus.RegisteringVoters;
    }

    function addVoter(address _voterAddress) external onlyOwner {
        require(currentSessionStatus == WorkflowStatus.RegisteringVoters, "You are not able to register voters now !");
        require(!voters[_voterAddress].isRegistered,"The voter is already registred");

        voters[_voterAddress] = Voter(true, false, false, 0);
        addresses.push(_voterAddress);

        emit VoterRegistered(_voterAddress);
    }

    function startProposalSession() external onlyOwner {
        require(currentSessionStatus == WorkflowStatus.RegisteringVoters,"You are not able to start a proposal session now !");

        currentSessionStatus = WorkflowStatus.ProposalsRegistrationStarted;
        time_now = block.timestamp;
        sessions[currentProposalSessionId].startTime = time_now;

        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function stopProposalSession() external onlyOwner {
        require(currentSessionStatus == WorkflowStatus.ProposalsRegistrationStarted, "Not proposals registration sessions is already started !");

        currentSessionStatus = WorkflowStatus.ProposalsRegistrationEnded;
        time_now = block.timestamp;
        sessions[currentProposalSessionId].endTime = time_now;

        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted,WorkflowStatus.ProposalsRegistrationEnded);
    }

    function submiteProposal(string memory _proposal) external {
        require(currentSessionStatus == WorkflowStatus.ProposalsRegistrationStarted, "You are not able to add a proposal !");
        require(voters[msg.sender].isRegistered, "You are not registered");
        require(!voters[msg.sender].hasProposed, "You already proposed");

        proposals.push(Proposal(currentProposalSessionId, msg.sender, _proposal, 0));
        
        voters[msg.sender].hasProposed = true;
        
        uint proposalId = proposals.length-1;
        emit ProposalRegistered(currentProposalSessionId, proposalId, msg.sender, _proposal);
    }

    function startVotingSession() external onlyOwner {
        require(currentSessionStatus == WorkflowStatus.ProposalsRegistrationEnded, "You are not able to start a voting session now !");
        
        currentSessionStatus = WorkflowStatus.VotingSessionStarted;
        
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);       
    }

    function StopVotingSession() external onlyOwner{
        require(currentSessionStatus == WorkflowStatus.VotingSessionStarted, "You are not able to stop a voting session now !");
        
        currentSessionStatus = WorkflowStatus.VotingSessionEnded;
        
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function submiteVote(uint16 _proposalId) external {
        require(currentSessionStatus == WorkflowStatus.VotingSessionStarted, "You are not able to vote !");        
        require(voters[msg.sender].isRegistered, "You can not vote !");
        require(!voters[msg.sender].hasVoted, "You already voted !");        
        require(proposals[_proposalId].sessionId == currentProposalSessionId, "Proposition inactive");      

        voters[msg.sender].votedProposalId = _proposalId;
        voters[msg.sender].hasVoted = true;
        proposals[_proposalId].voteCount++;

        emit Voted(msg.sender, currentProposalSessionId, _proposalId);
    }

    function countCurrentSessionVotes() external onlyOwner {
        require(currentSessionStatus == WorkflowStatus.VotingSessionEnded, "Session is still ongoing");
        
        currentSessionStatus = WorkflowStatus.VotesTallied;
        
        uint256 currentWinnerId;
        uint256 nbVotesWinner;
        uint256 totalVotes;

        for(uint16 i; i<proposals.length; i++){
            if (proposals[i].voteCount > nbVotesWinner){
                currentWinnerId = i;
                nbVotesWinner = proposals[i].voteCount;
            }
            totalVotes += proposals[i].voteCount;
        }
        
        winningProposalId = currentWinnerId;
        sessions[winningProposalId].endTime = block.timestamp;
        sessions[winningProposalId].winnerProposalName = proposals[winningProposalId].description;
        sessions[winningProposalId].winningProposerAddress = proposals[winningProposalId].proposerAddress;
        sessions[winningProposalId].nbVotes = nbVotesWinner;
        sessions[winningProposalId].totalVotes = totalVotes;       

        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        
    }

    function getWinner() external view returns(address winnerAddress){
        require(currentSessionStatus == WorkflowStatus.VotesTallied, "Counting votes not available for the moment"); 
        return proposals[winningProposalId].proposerAddress;
    }

    function getWinningProposalDetails() external view returns(string memory contentProposal, uint256 nbVotes, uint256 nbVotesTotal){
        require(currentSessionStatus == WorkflowStatus.VotesTallied, "Counting votes not available for the moment"); 
        return (
            proposals[winningProposalId].description,
            proposals[winningProposalId].voteCount,
            sessions[proposals[winningProposalId].sessionId].totalVotes
        );
    }

    function restartSession () external onlyOwner{
        require(currentSessionStatus == WorkflowStatus.VotesTallied, "Counting votes not finished yet"); 
  
        // Clear datas
        delete(proposals);
        for(uint i; i<addresses.length; i++){
            voters[addresses[i]].hasVoted = false;
            voters[addresses[i]].hasProposed = false;   
        }
        currentProposalSessionId++;
        currentSessionStatus = WorkflowStatus.RegisteringVoters;
        
        emit WorkflowStatusChange(WorkflowStatus.VotesTallied, WorkflowStatus.RegisteringVoters);
    }
}
