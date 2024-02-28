// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Counters.sol";
// Uncomment this line to use console.log
 import "hardhat/console.sol";

contract NFTMarktetplace is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint listingPrice= 0.0025 ether;

    address payable owner;
    modifier onlyOwner{
        require(owner ==msg.sender);
        _;
    }
    
    mapping(uint256=>MarketItem) private idMarketItem;
    struct MarketItem{
        uint tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    event idMarketItemCreated(
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

    constructor() ERC721("NFT name","MYNFT"){
        owner = payable(msg.sender);
    }

    function updateListingPrice(uint _listingPrice) public payable onlyOwner{
        listingPrice=_listingPrice;
    }

    function getListingPrice() public view returns(uint){
        return listingPrice;
    }

    function createToken(string memory _tokenURI, uint price) public payable returns(uint){
        _tokenIds.increment();
        uint newTokenId=_tokenIds.current();
        _mint(msg.sender,newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        creatMarketItem(newTokenId,price);
        return newTokenId;
    }

    function creatMarketItem(uint tokenId,uint price) private{
        require(price>0);
        require(msg.value == listingPrice);
         idMarketItem[tokenId] = MarketItem(tokenId, payable(msg.sender),payable(address(this)),price,false);
         _transfer(msg.sender,address(this),tokenId);
         emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }
    //FUNCTION FOR RESALE TOKEN
    function reSellToken(uint tokenId, uint price) public payable{
        require(idMarketItem[tokenId].owner==msg.sender);
        require(msg.value==listingPrice);
         idMarketItem[tokenId].sold=false;
         idMarketItem[tokenId].price=price;
         idMarketItem[tokenId].seller=payable(msg.sender);
         idMarketItem[tokenId].owner=payable(address(this));
         _itemsSold.decrement();
         _transfer(msg.sender,address(this),tokenId);
    }

    //FUNCTION CREATEMARKETSALE

    function createMarketSale(uint tokenId) public payable{
        uint price = idMarketItem[tokenId].price;
        require(msg.value == price);
        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold=true;
        //dooubt
        idMarketItem[tokenId].owner=payable(address(0));

        _itemsSold.increment();
        _transfer(address(this),msg.sender,tokenId);
        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);          
          
        }

        //GETTING UNSOLD NFT DATA

        function fetchMarketItem() public view returns(MarketItem[] memory){
            uint itemCount = _tokenIds.current();
            uint unSoldItemCount = _tokenIds.current()-_itemsSold.current();
            uint currentIndex=0; 
             
             MarketItem[] memory items = new MarketItem[](unSoldItemCount);
             for(uint i=0;i<itemCount;i++){
                if(idMarketItem[i+1].owner==address(this)){
                    uint currentId = i+1;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex+=1;
                }
             }
             return items;
        }

        //PURCHASE ITEM
        function fetchMyNft() public view returns(MarketItem[] memory){
            uint totalCount = _tokenIds.current();
            uint itemCount=0;
            uint currentIndex =0;

            for(uint i=0;i<totalCount;i++){
                if(idMarketItem[i+1].owner==msg.sender){
                    itemCount+=1;
                }
            }

            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i=0;i<totalCount;i++){
                if(idMarketItem[i+1].owner==msg.sender)
              {  uint currentId = i+1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex+=1;}
            }

            return items;
        }

        //SIGNULE USER ITEM
         function fetchItemsLists() public view returns(MarketItem[] memory){
            uint totalCount = _tokenIds.current();
            uint itemCount = 0;
            uint currentIndex=0;

            for(uint i=0;i<totalCount;i++){
                if(idMarketItem[i+1].seller==msg.sender){
                    itemCount+=1;
                }
            }

            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i=0;i<totalCount;i++){
                if(idMarketItem[i+1].seller==msg.sender)
               { uint currentId = i+1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex+=1;}
            }
            return items;

         }
  
    }
