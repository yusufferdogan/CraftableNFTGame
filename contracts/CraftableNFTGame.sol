// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract CraftableNFTGame is ERC721, ERC721Enumerable, ERC721Burnable, Ownable {
    enum CardsLevel {
        STONE,
        IRON,
        SILVER,
        GOLD,
        PHI
    }

    struct Card {
        uint256 cardId;
        uint256 weight;
    }

    IERC20 private immutable craftToken;
    using Counters for Counters.Counter;
    Counters.Counter internal tokenIds;
    string private baseUri = "https://";
    address payable internal addressOfThisContract;
    mapping(uint256 => Card) public cardData;

    constructor(address tokenAddress) ERC721("CraftableNFTGame", "CRAFT") {
        craftToken = IERC20(tokenAddress);
        addressOfThisContract = payable(address(this));
    }

    function setBaseURI(string memory _baseUri) public onlyOwner {
        baseUri = _baseUri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    function mint(uint256 inAmount) public {
        uint256 balance = craftToken.balanceOf(_msgSender());
        require(balance >= inAmount, "Not enough token in your balance");

        uint256 allowance = craftToken.allowance(_msgSender(), addressOfThisContract);
        require(allowance >= inAmount, "Approval needed for this address");

        require(
            craftToken.transferFrom(_msgSender(), addressOfThisContract, inAmount),
            "Transfer Error"
        );

        tokenIds.increment();
        uint256 newNftTokenId = tokenIds.current();

        Card memory newCard;
        newCard.cardId = totalSupply() % 4;
        newCard.weight = 1;

        cardData[newNftTokenId] = newCard;
        _mint(_msgSender(), newNftTokenId);
    }

    function merge(uint256 tokenId1, uint256 tokenId2) external {
        require(
            (ownerOf(tokenId1) == _msgSender() || getApproved(tokenId1) == _msgSender()) &&
                (ownerOf(tokenId2) == _msgSender() || getApproved(tokenId2) == _msgSender()),
            "Sender must have or approved tokens"
        );

        Card memory card1 = cardData[tokenId1];
        Card memory card2 = cardData[tokenId2];
        uint256 maxWeight = Math.max(card1.weight, card2.weight);
        uint256 mergeCost = _getMergeCost(maxWeight);

        uint256 balance = craftToken.balanceOf(_msgSender());
        require(balance >= mergeCost, "Not enough token in your balance");

        uint256 allowance = craftToken.allowance(_msgSender(), addressOfThisContract);
        require(allowance >= mergeCost, "Approval needed for this address");
    }

    function _getMergeCost(uint256 weight) private pure returns (uint256) {
        if (weight > 0 && weight < 5) {
            return 1;
        } else if (weight >= 5 && weight < 35) {
            return 2;
        } else if (weight >= 35 && weight < 75) {
            return 3;
        } else if (weight >= 75 && weight < 130) {
            return 4;
        } else if (weight >= 153) {
            return 5;
        } else revert("not valid weight");
    }

    function _getMergeTime(uint256 weight) private pure returns (uint256) {
        if (weight > 0 && weight < 5) {
            return 30 minutes;
        } else if (weight >= 5 && weight < 35) {
            return 2 hours;
        } else if (weight >= 35 && weight < 75) {
            return 12 hours;
        } else if (weight >= 75 && weight < 130) {
            return 1 days;
        } else if (weight >= 153) {
            return 7 days;
        } else revert("not valid weight");
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, amount);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }
}
