// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.3 < 0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Chessmates is ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private tokenID;

    string public uriPrefix = "";
    string public uriSuffix = ".json";
    string public hiddenMetadataUri;

    uint256 public cost = 0.08 ether;
    uint256 public supply = 10000;
    uint256 public maxMint = 5;

    bool public reveal = false;
    bool public hidden = true;

    bool public onlyWhitelisted = true;
    address[] public whiteList;
    mapping(address => uint256) public whiteListAddressBalance;

    address payable commissions = payable("INSERT COMMISSIONS ADDRESS HERE")

    constructor() ERC721("ChessMates", "CHESS"){
        setHiddenMetadataUri("ipfs://__CID__/hidden.json");
    }

    // Verifies mintLimit when minting
    modifier mintLimit(uint256 mintAmt) {
        require (mintAmt > 0 && mintAmt <= maxMint, "You may mint up to 5 Chessmates at a time");
        require(tokenID.current() + mintAmt <= supply, "Max Supply exceeded!");
    }

    //PUBLIC FUNCTIONS

    // Returns the current supply (current TokenID)
    function currentSupply() public view returns (uint256) {
        return tokenID.current();
    }

    // Whitelist check
    // Active/Pause Check
    // verifies transfer amount/value
    // calls mint function
    function mintNFT(uint256 mintAmt) public payable mintLimit(mintAmt) {
        if (msg.sender != owner()) {
            if (onlyWhitelisted == true) {
                require(isWhiteListed(msg.sender), "User is not Whitelisted");
                uint256 userMintCount = whiteListAddressBalance[msg.sender];
                require(userMintCount + mintAmt <= maxMint, "Mint limit exceeded");
                mint(msg.sender, mintAmt);
            }
        }
        require(!hidden, "Contract Paused" );
        require(msg.value >= cost * mintAmt, "Insufficient Funds To complete your Transaction!");
        mint(msg.sender, mintAmt);

        (bool success, ) = payable(commissions).call{value: msg.value * 5/100}("");
        require(success);
    }

    // Shows how many tokens are owned by an Address
    function OwnedTokens(address owner) public view returns uint256[] memory {
        uint256 ownerTokenCount = balanceOf(owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while(ownedTokenIndex < ownerTokenCount && currentTokenId <= supply) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;
            }
            currentTokenId++;
        }
        return ownedTokenIds;
    }

    // Checks if address is whitelisted
    function isWhitelisted(address userAddress) public view returns (bool) {
        for (uint256 i = 0; i < whiteList.length; i++) {
            if (whiteList[i] == userAddress) {
                return true;
            }
        }
        return false;
    }

    // OWNER FUNCTIONS

    // mints for another address
    function mintForAddress(uint256 mintAmt, address sendTo) public mintLimit(mintAmt) onlyOwner {
        mint(sendTo, mintAmt);
    }

    // Returns token Uri
    function tokenURI(uint256 token) public view virtual override returns (string memory) {
        require(_exists(token)), "Query for nonexistent TokenID");

        if (reveal == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, token.toString(), uriSuffix))
            : "";
    }

    // Reveals NFTs
    function setReveal(bool state) public onlyOwner {
        reveal = state;
    }
    
    // Hides NFTs
    function setHidden(bool state) public onlyOwner {
        hidden = state;
    }

    // Sets whitelist only mint
    function setWhitelistOnly(bool state) public onlyOwner {
        onlyWhitelisted = state;
    }

    // Adds addresses to whitelist
    function whitelistUsers(address[] calldata usersWhitelist) public onlyOwner {
        delete whiteList;
        whiteList = usersWhitelist;
    }

    // Sets new cost
    function setCost(uint256 newCost) public onlyOwner {
        cost = newCost;
    }
    // Sets new Mint limit per tx
    function setMintLimit(uint256 newMaxLimit) public onlyOwner {
        maxMint = newMaxLimit;
    }

    // Sets Uri for hidden Metadata
    function setHiddenMetadataUri(string memory hiddenUri) public onlyOwner {
        hiddenMetaDataUri = hiddenUri;
    }

    // Sets new Uri Suffix
    function setUriSuffix(string memory newUriSuffix) public onlyOwner {
        uriSuffix = newUriSuffix;
    }

    // Sets new Uri Prefix
    function setUriPrefix(string memory newUriPrefix) public onlyOwner {
        uriPrefix = newUriPrefix;
    }

    // Withdraw all funds to owner account
    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }

    // INTERNAL FUNCTIONS

    function mint(address reciever, uint256 mintAmt) internal {
        for (uint256 i = 0; i < mintAmt; i++) {
            tokenID.increment();
            _safeMint(reciever, tokenID.current());
        }
    }

    function baseURI() internal view returns (string memory) {
        return uriPrefix;
    }
}