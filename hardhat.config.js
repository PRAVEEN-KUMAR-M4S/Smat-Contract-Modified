require("@matterlabs/hardhat-zksync-solc");

/** @type import('hardhat/config').HardhatUserConfig */
const ALCHEMY_API_KEY="-3PAAOvjVZLKjonpUD_iBrceKkK0lCic";
const PRIVATE_KEY="62aee49a2cd807aeadaa18a3f859ba934e64306d81911f51e2f90cce81896db4";
const RPC_URL="https://eth-sepolia.g.alchemy.com/v2/";
module.exports = {

  defaultNetwork:"sepolia",
  networks: {
    
    sepolia:{
      url:`https://eth-sepolia.g.alchemy.com/v2//${ALCHEMY_API_KEY}`,
      accounts:[`0x${PRIVATE_KEY}`]
    } 
  },
  
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
