// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function UpdateCampaign(address _owner,uint256 _id,string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) external returns (uint256,string memory,string memory,uint256,string memory) {
            Campaign storage campaign = campaigns[_id];
            require(campaign.owner == _owner,"You ae not the owner");
        
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;

        return (_id,_title,_description,_target,_image);
    }

function deleteCampaign(uint256 _id) public {
  require(campaigns[_id].owner == msg.sender, "You are not the owner");

  Campaign storage campaignToDelete = campaigns[_id];
  uint256 totalAmountCollected = campaignToDelete.amountCollected;


  if (totalAmountCollected > 0) {
  
    for (uint256 i = 0; i < campaignToDelete.donators.length; i++) {
      address donator = campaignToDelete.donators[i];
      uint256 donationAmount = campaignToDelete.donations[i];
      (bool sent,) = payable(donator).call{value: donationAmount}("");
      if (sent) {

        totalAmountCollected=totalAmountCollected-donationAmount;
      }
    }
  }


  for (uint i = _id; i < numberOfCampaigns - 1; i++) {
    campaigns[i] = campaigns[i + 1];
  }


  delete campaigns[numberOfCampaigns - 1];

  numberOfCampaigns--;
}




    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}