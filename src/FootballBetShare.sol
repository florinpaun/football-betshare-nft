//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract FootballBetShare is ERC1155, Ownable {
    using Strings for uint256;

    uint256 public constant PLATFORM_FEE_PERCENT = 10;
    uint256 public constant CREATOR_FEE_PERCENT = 10;
    uint256 public constant BASIS_POINTS = 100;

    uint256 public gameCounter;
    uint256 public ticketCounter;

    uint256 public contractBalance;
    uint256 public totalFundsReceived;

    enum GameStatus {
        Created,
        Closed,
        Validated
    }
    enum Outcome {
        Draw,
        Home,
        Away
    }

    struct Game {
        uint256 id;
        string homeTeam;
        string awayTeam;
        uint256 oddsHome;
        uint256 oddsDraw;
        uint256 oddsAway;
        GameStatus status;
        Outcome result;
        bool resultSet;
    }

    struct TicketGame {
        uint256 gameId;
        uint256 selectedOdds;
    }

    struct BetTicket {
        uint256 id;
        address creator;
        TicketGame[] games;
        uint256 finalOdds;
        bytes32 hiddenDataHash;
        bool revealed;
        uint256[] revealedOutcomes;
        uint256 betAmount;
        uint256 totalMinted;
        uint256 totalStaked;
        bool settled;
    }

    mapping(uint256 => Game) public games;
    mapping(uint256 => BetTicket) public tickets;
    mapping(uint256 => mapping(address => uint256)) public userTicketBalance;

    event GameCreated(uint256 indexed gameId, string homeTeam, string awayTeam);
    event GameClosed(uint256 indexed gameId);
    event GameValidated(uint256 indexed gameId, Outcome result);
    event TicketCreated(
        uint256 indexed ticketId,
        address indexed creator,
        uint256 finalOdds
    );
    event TicketMinted(
        uint256 indexed ticketId,
        address indexed user,
        uint256 amount,
        uint256 value
    );
    event TicketRevealed(uint256 indexed ticketId, uint256[] outcomes);
    event WinningsDistributed(
        uint256 indexed ticketId,
        uint256 totalPayout,
        uint256 platformFee,
        uint256 creatorFee
    );
    event ContractFunded(address indexed funder, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event FallbackCalled(address indexed sender, uint256 amount);
    event ReceiveCalled(address indexed sender, uint256 amount);

    constructor() ERC1155("") Ownable(msg.sender) {}

    function fundContract() external payable {
        require(msg.value > 0, "Must send ETH to fund");

        contractBalance += msg.value;
        totalFundsReceived += msg.value;

        emit ContractFunded(msg.sender, msg.value);
    }

    function withdrawFunds(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be positive");
        require(address(this).balance >= _amount, "Insufficient balance");

        contractBalance -= _amount;
        payable(owner()).transfer(_amount);

        emit FundsWithdrawn(owner(), _amount);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        contractBalance = 0;
        payable(owner()).transfer(balance);

        emit FundsWithdrawn(owner(), balance);
    }

    receive() external payable {
        contractBalance += msg.value;
        totalFundsReceived += msg.value;

        emit ReceiveCalled(msg.sender, msg.value);
    }

    fallback() external payable {
        contractBalance += msg.value;
        totalFundsReceived += msg.value;

        emit FallbackCalled(msg.sender, msg.value);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function createGame(
        string memory _homeTeam,
        string memory _awayTeam,
        uint256 _oddsHome,
        uint256 _oddsDraw,
        uint256 _oddsAway
    ) external onlyOwner returns (uint256) {
        require(
            _oddsHome > 0 && _oddsDraw > 0 && _oddsAway > 0,
            "Invalid odds"
        );

        uint256 gameId = gameCounter++;

        Game storage game = games[gameId];
        game.id = gameId;
        game.homeTeam = _homeTeam;
        game.awayTeam = _awayTeam;
        game.oddsHome = _oddsHome;
        game.oddsDraw = _oddsDraw;
        game.oddsAway = _oddsAway;
        game.status = GameStatus.Created;

        emit GameCreated(gameId, _homeTeam, _awayTeam);
        return gameId;
    }

    function closeGame(uint256 _gameId) external onlyOwner {
        Game storage game = games[_gameId];
        require(
            game.status == GameStatus.Created,
            "Game not in created status"
        );

        game.status = GameStatus.Closed;
        emit GameClosed(_gameId);
    }

    function validateGameResult(
        uint256 _gameId,
        Outcome _result
    ) external onlyOwner {
        Game storage game = games[_gameId];
        require(game.status == GameStatus.Closed, "Game must be closed first");

        game.status = GameStatus.Validated;
        game.result = _result;
        game.resultSet = true;

        emit GameValidated(_gameId, _result);
    }

    function createTicket(
        uint256[] memory _gameIds,
        bytes32 _hiddenDataHash,
        uint256 _betAmount
    ) external returns (uint256) {
        require(_gameIds.length > 0, "Must include at least one game");
        require(_betAmount > 0, "Bet amount must be positive");

        uint256 ticketId = ticketCounter++;
        BetTicket storage ticket = tickets[ticketId];

        ticket.id = ticketId;
        ticket.creator = msg.sender;
        ticket.finalOdds = BASIS_POINTS;
        ticket.hiddenDataHash = _hiddenDataHash;
        ticket.betAmount = _betAmount;

        for (uint256 i = 0; i < _gameIds.length; i++) {
            uint256 gameId = _gameIds[i];

            require(games[gameId].id == gameId, "Game does not exist");
            require(
                games[gameId].status == GameStatus.Created,
                "Game not available for betting"
            );

            ticket.games.push(TicketGame({gameId: gameId, selectedOdds: 0}));
        }

        emit TicketCreated(ticketId, msg.sender, 0);
        return ticketId;
    }

    function mintTicket(uint256 _ticketId, uint256 _amount) external payable {
        BetTicket storage ticket = tickets[_ticketId];
        require(ticket.creator != address(0), "Ticket does not exist");
        require(!ticket.settled, "Ticket already settled");
        require(_amount > 0, "Amount must be positive");
        require(
            msg.value == ticket.betAmount * _amount,
            "Incorrect ETH amount"
        );

        for (uint256 i = 0; i < ticket.games.length; i++) {
            require(
                games[ticket.games[i].gameId].status == GameStatus.Created,
                "Game already closed"
            );
        }

        _mint(msg.sender, _ticketId, _amount, "");

        ticket.totalMinted += _amount;
        ticket.totalStaked += msg.value;
        userTicketBalance[_ticketId][msg.sender] += _amount;

        emit TicketMinted(_ticketId, msg.sender, _amount, msg.value);
    }

    function revealTicket(
        uint256 _ticketId,
        uint256[] memory _outcomes,
        string memory _salt
    ) external {
        BetTicket storage ticket = tickets[_ticketId];
        require(ticket.creator != address(0), "Ticket does not exist");
        require(!ticket.revealed, "Already revealed");
        require(
            _outcomes.length == ticket.games.length,
            "Invalid outcomes length"
        );
        require(
            msg.sender == owner() || msg.sender == ticket.creator,
            "Only owner or creator can reveal"
        );

        for (uint256 i = 0; i < ticket.games.length; i++) {
            Game storage game = games[ticket.games[i].gameId];
            require(
                game.status == GameStatus.Validated,
                "Not all games validated"
            );
        }

        bytes32 calculatedHash = keccak256(
            abi.encodePacked(_outcomes, _salt, ticket.creator)
        );
        require(
            calculatedHash == ticket.hiddenDataHash,
            "Hash verification failed"
        );

        ticket.revealed = true;
        ticket.revealedOutcomes = _outcomes;
        ticket.finalOdds = BASIS_POINTS;

        for (uint256 i = 0; i < ticket.games.length; i++) {
            uint256 outcome = _outcomes[i];
            require(outcome <= 2, "Invalid outcome");

            Game storage game = games[ticket.games[i].gameId];
            uint256 selectedOdds;

            if (outcome == 0) {
                selectedOdds = game.oddsDraw;
            } else if (outcome == 1) {
                selectedOdds = game.oddsHome;
            } else {
                selectedOdds = game.oddsAway;
            }

            ticket.games[i].selectedOdds = selectedOdds;
            ticket.finalOdds = (ticket.finalOdds * selectedOdds) / BASIS_POINTS;
        }

        emit TicketRevealed(_ticketId, _outcomes);
    }

    function settleTicket(uint256 _ticketId) external onlyOwner {
        BetTicket storage ticket = tickets[_ticketId];
        require(ticket.revealed, "Ticket not revealed");
        require(!ticket.settled, "Already settled");

        bool isWinning = checkTicketWin(_ticketId);

        if (isWinning && ticket.totalMinted > 0) {
            uint256 totalPayout = (ticket.totalStaked * ticket.finalOdds) /
                BASIS_POINTS;
            uint256 platformFee = (totalPayout * PLATFORM_FEE_PERCENT) /
                BASIS_POINTS;
            uint256 creatorFee = (totalPayout * CREATOR_FEE_PERCENT) /
                BASIS_POINTS;

            require(
                address(this).balance >= totalPayout,
                "Insufficient contract balance for payout"
            );

            payable(owner()).transfer(platformFee);
            payable(ticket.creator).transfer(creatorFee);

            ticket.settled = true;

            emit WinningsDistributed(
                _ticketId,
                totalPayout,
                platformFee,
                creatorFee
            );
        } else {
            payable(owner()).transfer(ticket.totalStaked);
            ticket.settled = true;
        }
    }

    function claimWinnings(uint256 _ticketId) external {
        BetTicket storage ticket = tickets[_ticketId];
        require(ticket.settled, "Ticket not settled");
        require(checkTicketWin(_ticketId), "Ticket is not a winner");

        uint256 userBalance = userTicketBalance[_ticketId][msg.sender];
        require(userBalance > 0, "No balance to claim");

        uint256 totalPayout = (ticket.totalStaked * ticket.finalOdds) /
            BASIS_POINTS;
        uint256 platformFee = (totalPayout * PLATFORM_FEE_PERCENT) /
            BASIS_POINTS;
        uint256 creatorFee = (totalPayout * CREATOR_FEE_PERCENT) / BASIS_POINTS;
        uint256 winnersPayout = totalPayout - platformFee - creatorFee;

        uint256 userShare = (winnersPayout * userBalance) / ticket.totalMinted;

        userTicketBalance[_ticketId][msg.sender] = 0;
        payable(msg.sender).transfer(userShare);
    }

    function checkTicketWin(uint256 _ticketId) public view returns (bool) {
        BetTicket storage ticket = tickets[_ticketId];
        if (!ticket.revealed) return false;

        for (uint256 i = 0; i < ticket.games.length; i++) {
            Game storage game = games[ticket.games[i].gameId];
            if (!game.resultSet) return false;

            uint256 predictedOutcome = ticket.revealedOutcomes[i];
            if (uint256(game.result) != predictedOutcome) {
                return false;
            }
        }
        return true;
    }

    function getGame(uint256 _gameId) external view returns (Game memory) {
        return games[_gameId];
    }

    function getTicket(
        uint256 _ticketId
    )
        external
        view
        returns (
            uint256 id,
            address creator,
            uint256 finalOdds,
            bool revealed,
            uint256 betAmount,
            uint256 totalMinted,
            uint256 totalStaked,
            bool settled
        )
    {
        BetTicket storage ticket = tickets[_ticketId];
        return (
            ticket.id,
            ticket.creator,
            ticket.finalOdds,
            ticket.revealed,
            ticket.betAmount,
            ticket.totalMinted,
            ticket.totalStaked,
            ticket.settled
        );
    }

    function getTicketGames(
        uint256 _ticketId
    ) external view returns (TicketGame[] memory) {
        return tickets[_ticketId].games;
    }

    function getRevealedOutcomes(
        uint256 _ticketId
    ) external view returns (uint256[] memory) {
        require(tickets[_ticketId].revealed, "Ticket not revealed");
        return tickets[_ticketId].revealedOutcomes;
    }
}
