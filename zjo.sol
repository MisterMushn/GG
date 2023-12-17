// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public name = "MyToken";
    string public symbol = "MT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10 ** uint256(decimals);
    address public owner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => address) public referrers;
    mapping(address => uint256) public referralBonuses;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }
    
    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        
        // Calculate referral bonus if there is a referrer
        if (referrers[to] != address(0)) {
            uint256 referralBonus = (value * 5) / 100; // 5% referral bonus
            referralBonuses[referrers[to]] += referralBonus;
        }
        
        // Transfer tokens
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    // Register a referrer
    function registerReferrer(address referrer) external {
        require(referrer != address(0) && referrer != msg.sender, "Invalid referrer address");
        require(referrers[msg.sender] == address(0), "You already have a referrer");
        
        referrers[msg.sender] = referrer;
    }
    
    // Withdraw referral bonuses
    function withdrawReferralBonuses() external {
        uint256 referralBonus = referralBonuses[msg.sender];
        require(referralBonus > 0, "No referral bonuses to withdraw");
        
        referralBonuses[msg.sender] = 0;
        // Transfer the referral bonus to the user
        payable(msg.sender).transfer(referralBonus);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenWithReferral {
    string public name = "TokenWithReferral";
    string public symbol = "TWR";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10 ** uint256(decimals);
    address public owner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => address) public referrers;
    mapping(address => uint256) public referralBonuses;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }
    
    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        
        // Calculate referral bonuses if there are referrers
        if (referrers[msg.sender] != address(0)) {
            uint256 referralCut = (value * 5) / 100; // 5% referral cut for the sender
            uint256 referrerCut = (value * 5) / 100; // 5% referral cut for the referrer
            
            // Distribute referral bonuses
            referralBonuses[msg.sender] += referralCut;
            referralBonuses[referrers[msg.sender]] += referrerCut;
        }
        
        // Transfer tokens
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    // Register a referrer
    function registerReferrer(address referrer) external {
        require(referrer != address(0) && referrer != msg.sender, "Invalid referrer address");
        require(referrers[msg.sender] == address(0), "You already have a referrer");
        
        referrers[msg.sender] = referrer;
    }
    
    // Withdraw referral bonuses
    function withdrawReferralBonuses() external {
        uint256 referralBonus = referralBonuses[msg.sender];
        require(referralBonus > 0, "No referral bonuses to withdraw");
        
        referralBonuses[msg.sender] = 0;
        // Transfer the referral bonus to the user
        payable(msg.sender).transfer(referralBonus);
    }
}
