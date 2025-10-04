// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TexiFiInvoice is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;

    struct Invoice {
        string invoiceId;
        uint256 amount;
        address seller;
        address buyer;
        bool paid;
    }

    mapping(uint256 => Invoice) public invoices;

    event InvoiceMinted(uint256 tokenId, string invoiceId, address seller, address buyer, string uri);
    event InvoicePaid(uint256 tokenId, address payer);

    constructor() ERC721("TexiFiInvoice", "TFI") Ownable(msg.sender) {}

    // Mint a new invoice NFT
    function mintInvoice(
        string memory invoiceId,
        uint256 amount,
        address buyer,
        string memory tokenURI
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        invoices[tokenId] = Invoice({
            invoiceId: invoiceId,
            amount: amount,
            seller: msg.sender,
            buyer: buyer,
            paid: false
        });

        nextTokenId++;
        emit InvoiceMinted(tokenId, invoiceId, msg.sender, buyer, tokenURI);
        return tokenId;
    }

    // Mark an invoice as paid (only buyer can do this)
    function markAsPaid(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Invalid tokenId");
        require(msg.sender == invoices[tokenId].buyer, "Only buyer can mark as paid");
        require(!invoices[tokenId].paid, "Invoice already paid");

        invoices[tokenId].paid = true;
        emit InvoicePaid(tokenId, msg.sender);
    }

    // View full invoice details
    function getInvoice(uint256 tokenId) external view returns (Invoice memory) {
        require(_ownerOf(tokenId) != address(0), "Invalid tokenId");
        return invoices[tokenId];
    }
}

