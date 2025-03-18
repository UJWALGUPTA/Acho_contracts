// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AchoAdPayments is Ownable {
    IERC20 public achoToken;

    uint256 public platformFeePercentage = 10; // 10% fee to platform
    address public platformWallet;

    struct AdCampaign {
        address advertiser;
        uint256 amountPaid;
        address[] communityOwners;
        uint256[] revenueShare;
        bool isValidated;
        bool isPaid;
    }

    mapping(uint256 => AdCampaign) public campaigns;
    uint256 public campaignCounter;

    event CampaignCreated(
        uint256 indexed campaignId,
        address advertiser,
        uint256 amountPaid
    );
    event AdValidated(uint256 indexed campaignId, bool isValidated);
    event PaymentDistributed(uint256 indexed campaignId, uint256 amountPaid);

    constructor(
        address _achoToken,
        address _platformWallet,
        address initialOwner
    ) Ownable(initialOwner) {
        achoToken = IERC20(_achoToken);
        platformWallet = _platformWallet;
    }

    function createCampaign(
        uint256 _amount,
        address[] calldata _communityOwners,
        uint256[] calldata _revenueShare
    ) external {
        require(
            _communityOwners.length == _revenueShare.length,
            "Mismatched revenue shares"
        );
        require(_amount > 0, "Amount must be greater than zero");

        uint256 totalShare;
        for (uint256 i = 0; i < _revenueShare.length; i++) {
            totalShare += _revenueShare[i];
        }
        require(totalShare <= 100, "Revenue share exceeds 100%");

        require(
            achoToken.transferFrom(msg.sender, address(this), _amount),
            "Payment failed"
        );

        uint256 campaignId = campaignCounter++;

        campaigns[campaignId] = AdCampaign({
            advertiser: msg.sender,
            amountPaid: _amount,
            communityOwners: _communityOwners,
            revenueShare: _revenueShare,
            isValidated: false,
            isPaid: false
        });

        emit CampaignCreated(campaignId, msg.sender, _amount);
    }

    function validateAd(uint256 _campaignId) external onlyOwner {
        require(!campaigns[_campaignId].isValidated, "Ad already validated");
        campaigns[_campaignId].isValidated = true;
        emit AdValidated(_campaignId, true);
    }

    function distributePayments(uint256 _campaignId) external {
        AdCampaign storage campaign = campaigns[_campaignId];
        require(campaign.isValidated, "Ad must be validated first");
        require(!campaign.isPaid, "Payment already distributed");

        uint256 platformFee = (campaign.amountPaid * platformFeePercentage) /
            100;
        require(
            achoToken.transfer(platformWallet, platformFee),
            "Platform fee transfer failed"
        );

        uint256 remainingBalance = campaign.amountPaid - platformFee;
        for (uint256 i = 0; i < campaign.communityOwners.length; i++) {
            uint256 payout = (remainingBalance * campaign.revenueShare[i]) /
                100;
            require(
                achoToken.transfer(campaign.communityOwners[i], payout),
                "Community payout failed"
            );
        }

        campaign.isPaid = true;
        emit PaymentDistributed(_campaignId, campaign.amountPaid);
    }

    function updatePlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 20, "Fee cannot exceed 20%");
        platformFeePercentage = _newFee;
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(achoToken.transfer(msg.sender, _amount), "Withdrawal failed");
    }
}
