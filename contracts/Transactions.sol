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
        bool approvalStatus;
        bool requestStatus;
        bool deleteStatus;
       
        address[] donators;
        uint256[] donations;
    }

        struct Request{
        address campaignOwner;
        uint256 campaignId;
        uint256 amount;
        string campaignTitle;
        bool approvalStatus;
        bool requestStatus;
        bool deleteStatus;
        bool deleteDone;
      
    }

    address   contractOwner=0x12973DEC5eeAb980C581722dFC35206CecFd1a11;
    mapping(uint256=>Request) private requests;
    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;
    uint256 public numberOfRequest = 0;

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


    
    function withdrawalRequest(uint256 _id) public returns(uint256){
       
        Request storage request = requests[numberOfRequest];
        Campaign storage campaign = campaigns[_id];

          

        
       

      request.campaignOwner=campaign.owner;
      request.campaignId=_id;
      request.amount=campaign.amountCollected;
      request.campaignTitle=campaign.title;
      request.approvalStatus=false;
      request.requestStatus=true;
      campaign.approvalStatus=false;
      campaign.requestStatus=true;
    


      numberOfRequest++;

      return numberOfRequest-1;
      

    }

    function deleteRequest(uint256 _id) public returns(uint256){
       
        Request storage request = requests[numberOfRequest];
        Campaign storage campaign = campaigns[_id];

          

        
       

      request.campaignOwner=campaign.owner;
      request.campaignId=_id;
      request.amount=campaign.amountCollected;
      request.campaignTitle=campaign.title;
      request.deleteStatus=true;
      campaign.deleteStatus=true;
    


      numberOfRequest++;

      return numberOfRequest-1;
      

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

    function deleteCampaignAuto(uint256 _id) public {
 

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

function deleteCampaign(uint256 _id,uint256 _qid) public {
 

  Campaign storage campaignToDelete = campaigns[_id];
   Request storage request = requests[_qid];
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
  request.deleteDone=true;

  numberOfCampaigns--;
  
}


function approvalRequest(uint256 _id,uint256 _qid) public payable {
    uint256 amount = msg.value;
    Request storage request = requests[_qid];
    Campaign storage campaign = campaigns[_id];
   
    
    (bool sent,) = payable(request.campaignOwner).call{value: amount}("");
    
    if (sent) {
        request.approvalStatus = true;
        request.requestStatus=false;
        campaign.approvalStatus=true;
    

    }
}




    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(contractOwner).call{value: amount}("");

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

    function getRequests() public view returns (Request[] memory) {
    Request[] memory allRequests = new Request[](numberOfRequest);

    for(uint i = 0; i < numberOfRequest; i++) {
        allRequests[i] = requests[i];
    }

    return allRequests;
}

function getBalance(address _address) public view returns (uint256) {
    return _address.balance;
}




    
}