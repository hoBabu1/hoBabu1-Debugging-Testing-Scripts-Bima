//  Run command : $ npx hardhat run scripts/refreshAll.ts
import { ethers, config as hreConfig } from "hardhat";

const networksAndAddresses: { [network: string]: string } = {
    rootstock_testnet: "0x584B370b8b7d6BFF7932C21cd5A7055363B95a8c",
    monad_testnet: "0xEc63b8a3a2402892d3E6AB97b89CF47132a29dAa",
    botanix_testnet: "0xC7638947e29EFC01F9B47215FD43f603D98f4aB5",
    nero_testnet: "0x9540dd2AF8242518562101b42D71Ce2ec169A5a3",
    taker_testnet: "0xE20B0B5E240910Ca1461893542C6F226793aAD25",
};

async function refreshMockOracle(wallet: any, network: string, address: string) {
    try {
        console.log(`Refreshing MockOracle on network: ${network} for address: ${address}`);
        const MockOracle = await ethers.getContractFactory("MockOracle", wallet);
        const mockOracle: any = MockOracle.attach(address);
        console.log("Calling the refresh() function...");
        const refreshTx = await mockOracle.refresh();
        await refreshTx.wait();
        console.log("refresh() function called successfully.");
        const [roundId, answer, startedAt, updatedAt, answeredInRound] = await mockOracle.latestRoundData();
        console.log("Updated round data after refresh:");
        console.log(`Round ID: ${roundId}`);
        console.log(`Answer: ${answer}`);
        console.log(`Started At: ${startedAt}`);
        console.log(`Updated At: ${updatedAt}`);
        console.log(`Answered In Round: ${answeredInRound}`);
    } catch (error) {
        console.error(`Error refreshing MockOracle on network ${network}:`, error);
    }
}

async function main() {
    const networksConfig = hreConfig.networks;
    const privateKey = process.env.PRIVATE_KEY;
    if (!privateKey) {
        throw new Error("PRIVATE_KEY environment variable is not set.");
    }

    for (const [networkName, address] of Object.entries(networksAndAddresses)) {
        const netConfig: any = networksConfig[networkName];
        if (!netConfig || !netConfig.url) {
            console.error(`Configuration for network ${networkName} is missing in hardhat.config.ts`);
            continue;
        }
        const provider = new ethers.JsonRpcProvider(netConfig.url);
        const wallet = new ethers.Wallet(privateKey, provider);
        await refreshMockOracle(wallet, networkName, address);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
