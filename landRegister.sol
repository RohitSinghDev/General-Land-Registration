// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";



contract landRegistration is Ownable
{
    struct landRegistry{
        address landOwner;
        uint landId;
        uint area;
        string city;
        string state;
        uint landPriceInWei;
        uint propertyPID;
    }

    struct buyerDetails{
        string Name;
        uint256 Age;
        string city;
        string CNIC;
        string eMail;
    } 

    struct sellerDetails{
        string Name;
        uint256 Age;
        string city;
        string CNIC;
        string eMail;
    }

    struct landInspectorDetails{
        address landInspectorAddress;
        string Name;
        uint Age;
        string designation;
    }

 
    mapping (uint => landRegistry) private lands;
    mapping (uint => landInspectorDetails) private inspectorMapping;
    mapping (address => sellerDetails) private sellerMapping;
    mapping (address => buyerDetails) private buyerMapping;
    mapping (address => bool) private verifySeller;
    mapping (address => bool) private verifyBuyer;
    mapping (uint => bool) private verifyLandID;


    uint private inspectorId=1;
    uint private LandID=1;
    address public sellerAddress;
    address public buyerAddress;
    bool landPricePaid=false;


    event landInspectorHired(address ownerAddress, string Name);

    event BuyerVerified(address _buyerAddress, string );

    event SellerVerified(address _sellerAddress, string ); 

    event LandVerified(address _landOwner, uint LandID);

    event transferLandPrice(address _buyerAddress, address _sellerAddress, uint _landID, uint _landPrice);

    event transferOwnershipLog(address _currentOwner, address _newOwner, uint _landID);

    modifier IsVerifiedSeller()
    {
        require(verifySeller[msg.sender],"Unverified Seller");
        _;
    }

    modifier IsVerifiedBuyer()
    {
        require(verifyBuyer[msg.sender],"Unverified Buyer");
        _;
    }

    modifier IsVerifiedLand(uint _landId)
    {
        require(verifyLandID[_landId],"Unverified Land ID");
        _;
    }

    
    function landInspectorData(
        string memory _Name, uint _Age, string memory _designation
    ) public onlyOwner
    {
        inspectorMapping[inspectorId]=landInspectorDetails(msg.sender, _Name, _Age, _designation);
        emit landInspectorHired(msg.sender, _Name);
    }

 

    function registerSeller(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external 
    {
        sellerAddress = msg.sender;
        require(sellerAddress!=buyerAddress, "Seller can't be Buyer");
        sellerMapping[sellerAddress]=sellerDetails(_Name, _Age, _city, _CNIC, _eMail);
    }


    function VerifySeller( address _SellerAddress)
    public onlyOwner
    {
        verifySeller[_SellerAddress] = true;

        emit SellerVerified(_SellerAddress, "Seller is Verified");
    }
  

    function uploadLandDetails(
        uint _landId, uint _area, string memory _city, string memory _state, uint _landPriceInWei, uint _propertyPID
    ) external IsVerifiedSeller 
    {
        lands[LandID]=landRegistry(msg.sender, _landId, _area, _city, _state, _landPriceInWei, _propertyPID);
    }


    function verifyLandId( uint _Land_ID)
    public onlyOwner
    {
        require(lands[LandID].landId == _Land_ID, "Incorrect Land ID");
        verifyLandID[_Land_ID]= true;

        emit LandVerified(lands[LandID].landOwner, _Land_ID);
    }



    function updateSeller(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external IsVerifiedSeller
    {
        sellerMapping[msg.sender].Name= _Name;
        sellerMapping[msg.sender].Age= _Age;
        sellerMapping[msg.sender].city= _city;
        sellerMapping[msg.sender].CNIC= _CNIC;
        sellerMapping[msg.sender].eMail= _eMail;
    }



    function sellerIsVerified(address _sellerAddress) 
    external view returns(bool)
    {
        if (verifySeller[_sellerAddress])
        {
            return true;
        }
        else{
            return false;
        } 
    }


    function getLandDetailsByID (uint _landId
    ) external view returns (address, uint, uint , string memory, string memory, uint, uint)
    {
        require(_landId == lands[LandID].landId,"Incorrect Land ID");
        return (lands[LandID].landOwner, lands[LandID].landId, lands[LandID].area, lands[LandID].city, lands[LandID].state, lands[LandID].landPriceInWei, lands[LandID].propertyPID) ;
    }


    
    function getLandOwnerByID (uint _landId
    ) external view returns (address)
    {
        require(_landId == lands[LandID].landId,"Incorrect Land ID");
        return lands[LandID].landOwner;
    }



    function registerBuyer(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external 
    {
        buyerAddress = msg.sender;
        require(buyerAddress!=sellerAddress, "Seller can't be Buyer");
        buyerMapping[buyerAddress]=buyerDetails(_Name, _Age, _city, _CNIC, _eMail);
    }


    function VerifyBuyer( address _buyerAddress)
    public onlyOwner
    {
        verifyBuyer[_buyerAddress] = true;

        emit BuyerVerified(msg.sender, "Buyer is Verified");
    }



     function updateBuyer(
        string memory _Name,uint _Age,string memory  _city,string memory _CNIC,string memory _eMail
    ) external IsVerifiedBuyer
    {
        buyerMapping[msg.sender].Name= _Name;
        buyerMapping[msg.sender].Age= _Age;
        buyerMapping[msg.sender].city= _city;
        buyerMapping[msg.sender].CNIC= _CNIC;
        buyerMapping[msg.sender].eMail= _eMail;
    }

 

    function buyerIsVerified(address _buyerAddress) 
    external view returns(bool)
    {
        if (verifyBuyer[_buyerAddress])
        {
            return true;
        }
        else{
            return false;
        } 
    }

  

    function currentOwnerOFLand () 
    external view returns(address)
    {
        return lands[LandID].landOwner;
    }

 

    function buyLand(address payable _sellerAddress, uint _landId)
    public IsVerifiedBuyer IsVerifiedLand(_landId) payable returns( bool)
    {
        require(verifySeller[_sellerAddress], "Unverified Seller");
        require(lands[LandID].landPriceInWei==msg.value, "Recheck Your Land Price in wei.");

        _sellerAddress.transfer(msg.value);
        landPricePaid = true;

        emit transferLandPrice(msg.sender, _sellerAddress, _landId, msg.value);
        return  true;
    } 


    function changeOwnership (address _buyerAddress)
    public IsVerifiedSeller payable returns(address, string memory)
    {
        require(verifyBuyer[_buyerAddress], "Unverified Buyer");
        require(landPricePaid, "Price Not Paid");
        lands[LandID].landOwner= _buyerAddress;

        emit transferOwnershipLog(msg.sender, _buyerAddress, lands[LandID].landId);
        return (lands[LandID].landOwner, "New Owner of Land");
    }

 

    function LandIsVerified(uint _landId) 
    external view returns(bool)
    {
        if (verifyLandID[_landId])
        {
            return true;
        }
        else{
            return false;
        }
    }


    function GetLandInspectorData()
    external view returns(address, string memory, uint, string memory)
    {
        return(inspectorMapping[inspectorId].landInspectorAddress, inspectorMapping[inspectorId].Name, inspectorMapping[inspectorId].Age, inspectorMapping[inspectorId].designation );
    }

 

    function getLandCityByID (uint _landId
    ) external view returns (string memory)
    {
        require(lands[LandID].landId == _landId ,"Incorrect Land ID");
        return lands[LandID].city;
    }



    function getLandPriceByID (uint _landId
    ) external view returns (uint)
    {
        require(lands[LandID].landId == _landId ,"Incorrect Land ID");
        return lands[LandID].landPriceInWei;
    }


    function getLandAreaByID (uint _landId
    ) external view returns (uint)
    {
        require(lands[LandID].landId == _landId ,"Incorrect Land ID");
        return lands[LandID].area;
    }


    function isSeller()
    external view returns(bool)
    {
        if(msg.sender == sellerAddress)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    function isBuyer()
    external view returns(bool)
    {
        if(msg.sender == buyerAddress)
        {
            return true;
        }
        else
        {
            return false;
        }
    }    
 }