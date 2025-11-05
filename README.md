# Football BetShare NFT

A decentralized betting platform where users can create, share, and trade football betting tickets as ERC-1155 NFTs. Ticket creators hide their predictions using cryptographic hashing, and other users can mint shares of these tickets to participate in the bet.

## 🎯 Features

- **NFT-based Betting Tickets**: Each betting ticket is an ERC-1155 token that can be minted by multiple users
- **Commit-Reveal Scheme**: Ticket creators commit their predictions using cryptographic hashing before games close
- **Multi-Game Parlays**: Combine multiple games into a single ticket with cumulative odds
- **Decentralized Ownership**: Built on Ethereum with transparent smart contract logic
- **Fee Distribution**: Automatic distribution of platform and creator fees upon winning

## 📋 Table of Contents

- [How It Works](#how-it-works)
- [Installation](#installation)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Contract Architecture](#contract-architecture)
- [License](#license)

## 🔄 How It Works

### 1. Game Creation (Owner Only)
The contract owner creates games with odds for Home/Draw/Away outcomes:
```solidity
createGame("Manchester United", "Liverpool", 250, 300, 180)
// Odds: Home 2.5x, Draw 3.0x, Away 1.8x (basis points: 100 = 1x)
```

### 2. Ticket Creation
Users create betting tickets by:
- Selecting multiple games
- Choosing predictions (0=Draw, 1=Home, 2=Away) for each game
- Hashing their predictions with a salt: `keccak256(outcomes, salt, creator)`
- Setting a bet amount per share

### 3. Ticket Minting
Other users can mint shares of any ticket by paying the bet amount per share. This creates a pool of bettors sharing the same predictions.

### 4. Game Closure & Validation
- Owner closes games when betting ends
- Owner validates game results after matches complete

### 5. Ticket Reveal
After all games are validated, the ticket creator reveals their predictions with the original salt. The contract verifies the hash and calculates final odds.

### 6. Settlement & Claiming
- Owner settles the ticket
- Winners claim their proportional share of the winnings
- Losers' stakes go to the contract owner

## 🛠 Installation

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)
- Node.js (optional, for additional tooling)

### Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd football-betshare-nft

# Install dependencies
forge install

# Build the project
forge build
```

## ⚙️ Configuration

### Environment Setup

Create a `.env` based on `.env.example` file in the project root:

```env
# Local development (Anvil)
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://127.0.0.1:8545

# Testnet deployment (e.g., Sepolia)
# PRIVATE_KEY=your_testnet_private_key
# RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-api-key
# ETHERSCAN_API_KEY=your_etherscan_api_key

# Mainnet deployment (use with caution)
# PRIVATE_KEY=your_mainnet_private_key
# RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your-api-key
```

### Foundry Configuration

Update `foundry.toml`:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
optimizer = true
optimizer_runs = 200
via_ir = true  # Helps reduce contract size
```

## 🚀 Deployment

### Local Deployment (Anvil)

```bash
# Start local Ethereum node
anvil

# In a new terminal, deploy the contract
forge script script/Deploy.s.sol:DeployFootballBetShare \
  --rpc-url $RPC_URL \
  --broadcast
```

## 📖 Usage

### Interacting with the Contract

#### Using Cast (Foundry CLI)

```bash
# Set contract address
CONTRACT_ADDRESS=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0

# Fund the contract
cast send $CONTRACT_ADDRESS "fundContract()" \
  --value 10ether \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Create a game (owner only)
cast send $CONTRACT_ADDRESS \
  "createGame(string,string,uint256,uint256,uint256)" \
  "Manchester United" "Liverpool" 250 300 180 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Check game details
cast call $CONTRACT_ADDRESS "getGame(uint256)" 0 --rpc-url $RPC_URL

# Close a game (owner only)
cast send $CONTRACT_ADDRESS "closeGame(uint256)" 0 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Validate game result (owner only, 0=Draw, 1=Home, 2=Away)
cast send $CONTRACT_ADDRESS "validateGameResult(uint256,uint8)" 0 1 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

### Example Workflow

```bash
# 1. Owner creates games
cast send $CONTRACT_ADDRESS "createGame(string,string,uint256,uint256,uint256)" \
  "Real Madrid" "Barcelona" 220 280 200 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

cast send $CONTRACT_ADDRESS "createGame(string,string,uint256,uint256,uint256)" \
  "PSG" "Bayern Munich" 190 290 240 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 2. User creates a ticket (use JavaScript to generate hash)
# Assuming hash is: 0x1234...
cast send $CONTRACT_ADDRESS \
  "createTicket(uint256[],bytes32,uint256)" \
  "[0,1]" \
  "0x1234..." \
  "100000000000000000" \
  --rpc-url $RPC_URL \
  --private-key $USER_PRIVATE_KEY

# 3. Other users mint shares of the ticket
cast send $CONTRACT_ADDRESS "mintTicket(uint256,uint256)" 0 5 \
  --value 0.5ether \
  --rpc-url $RPC_URL \
  --private-key $OTHER_USER_KEY

# 4. Owner closes games
cast send $CONTRACT_ADDRESS "closeGame(uint256)" 0 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
cast send $CONTRACT_ADDRESS "closeGame(uint256)" 1 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 5. Owner validates results
cast send $CONTRACT_ADDRESS "validateGameResult(uint256,uint8)" 0 1 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
cast send $CONTRACT_ADDRESS "validateGameResult(uint256,uint8)" 1 2 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 6. Creator reveals predictions
cast send $CONTRACT_ADDRESS \
  "revealTicket(uint256,uint256[],string)" \
  0 "[1,2]" "my-secret-salt-12345" \
  --rpc-url $RPC_URL \
  --private-key $USER_PRIVATE_KEY

# 7. Owner settles the ticket
cast send $CONTRACT_ADDRESS "settleTicket(uint256)" 0 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 8. Winners claim their share
cast send $CONTRACT_ADDRESS "claimWinnings(uint256)" 0 --rpc-url localhost --private-key $WINNER_KEY
```

## 🏗 Contract Architecture

### Key Components

#### Game Management
- `createGame()`: Create new betting games with odds
- `closeGame()`: Close betting on a game
- `validateGameResult()`: Set the final result of a game

#### Ticket Lifecycle
- `createTicket()`: Create a new betting ticket with hidden predictions
- `mintTicket()`: Mint shares of an existing ticket
- `revealTicket()`: Reveal predictions after games are validated
- `settleTicket()`: Finalize ticket and distribute fees
- `claimWinnings()`: Users claim their winnings

#### Fee Structure
- **Platform Fee**: 10% of total payout
- **Creator Fee**: 10% of total payout
- **Winners Share**: 80% of total payout (distributed proportionally)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [ERC-1155 Standard](https://eips.ethereum.org/EIPS/eip-1155)


**Disclaimer**: This smart contract is provided as-is for educational purposes. Always conduct thorough testing and security audits before deploying to mainnet.