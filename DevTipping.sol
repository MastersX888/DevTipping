pragma solidity ^0.8.0;

contract DevTipping {
    address public owner;
    uint256 public platformFeePercent = 3;
    mapping(address => uint256) public developerBalances;
    mapping(string => address) public githubToAddress; // GitHub username to ETH address
    mapping(address => uint256) public totalTipsReceived; // Track total tips per dev

    event TipSent(address indexed from, address indexed to, uint256 amount, uint256 fee);
    event GithubRegistered(string githubUsername, address developer);

    constructor() {
        owner = msg.sender;
    }

    function registerGithub(string memory githubUsername) external {
        require(githubToAddress[githubUsername] == address(0), "Username already registered");
        githubToAddress[githubUsername] = msg.sender;
        emit GithubRegistered(githubUsername, msg.sender);
    }

    function sendTip(address payable developer) external payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        require(developer != address(0), "Invalid developer address");

        uint256 fee = (msg.value * platformFeePercent) / 100;
        uint256 tipAmount = msg.value - fee;

        developerBalances[developer] += tipAmount;
        developerBalances[owner] += fee;
        totalTipsReceived[developer] += tipAmount;

        emit TipSent(msg.sender, developer, tipAmount, fee);
    }

    function withdraw() external {
        uint256 balance = developerBalances[msg.sender];
        require(balance > 0, "No funds to withdraw");
        developerBalances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }

    function getBalance(address developer) external view returns (uint256) {
        return developerBalances[developer];
    }
}