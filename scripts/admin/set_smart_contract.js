const fs = require("fs");
const path = require("path");
require("dotenv").config();

const resources = {
	LoyaltyToken: {
		artifact: "./../../artifacts/contracts/core/LoyaltyToken.sol/LoyaltyToken.json",
		type: 2,
		needsAddress: true,
	},
	LoyaltyTokenManager: {
		artifact: "./../../artifacts/contracts/core/LoyaltyTokenManager.sol/LoyaltyTokenManager.json",
		type: 1,
		needsAddress: true,
	},

	BusinessToken: {
		artifact: "./../../artifacts/contracts/core/BusinessToken.sol/BusinessToken.json",
		type: 4,
		needsAddress: true,
	},
	BusinessTokenManager: {
		artifact: "./../../artifacts/contracts/core/BusinessTokenManager.sol/BusinessTokenManager.json",
		type: 3,
		needsAddress: true,
	},
};

const setSmartContract = (contractName) => {
	const source = (() => {
		try {
			return JSON.parse(fs.readFileSync(path.resolve(__dirname, resources[contractName].artifact)).toString());
		} catch (e) {
			return "";
		}
	})();

	if (source === "") {
		console.error(`Error: ${contractName} Details: Missing Source File`);
		return;
	}

	const abiAsExpected = { abi: source.abi };
	const jsonABI = JSON.stringify(abiAsExpected) || "";

	const contractAddress = getContractAddress(contractName) || "";
	const sourceBytecode = source.bytecode || "";

	//Run Validations
	if (resources[contractName].needsAddress && contractAddress === "") {
		console.error(`Error: ${contractName} Details: Missing Address`);
		return;
	}

	if (!resources[contractName].needsAddress && sourceBytecode === "") {
		console.error(`Error: ${contractName} Details: Missing Bytecode`);
		return;
	}

	if (jsonABI === "") {
		console.error(`Error: ${contractName} Details: Missing ABI`);
		return;
	}

	const requestData = {
		ABI: jsonABI,
		ByteCode: sourceBytecode,
		ContractAddress: contractAddress,
		SmartContractType: resources[contractName].type || 0,
	};

	const requestDataJSON = JSON.stringify(requestData);

	// Username and password
	const username = process.env.OS_ADMIN;
	const password = process.env.OS_ADMIN_PASS;

	// Base64 encode the credentials
	const credentials = btoa(username + ":" + password);

	// Create the Authorization header
	const authHeaderValue = `Basic ${credentials}`;

	fetch(`https://personal-ixqe4210.outsystemscloud.com/BusinessOnChain_API/rest/Admin/UploadSmartContractCode`, {
		headers: {
			Authorization: authHeaderValue,
			"Content-Type": "application/json",
		},
		method: "POST",
		body: requestDataJSON,
	})
		.then((response) => {
			if (!response.ok) {
				console.error("Network response was not ok " + response.statusText);
			} else {
				console.log(`Sent: ${contractName}`);
			}
		})
		.catch((error) => console.error("There was a problem with your fetch operation:", error));
};

const getContractAddress = (contractName) => {
	const source = JSON.parse(fs.readFileSync(path.resolve(__dirname, "./../../ignition/deployments/chain-11011/deployed_addresses.json")).toString());
	const addresses = {};
	Object.keys(source).forEach((key) => {
		const newKey = key.split("#")[1];
		addresses[newKey] = source[key];
	});

	return addresses[contractName];
};

module.exports = {
	setSmartContract,
};

const commands = {
	help: { name: "help", description: "See command options" },
	all: {
		name: "all",
		description: "Send all  contracts ",
	},
};

const main = () => {
	const baseParam = process.argv.length > 2 ? process.argv[2] : commands.help.name;
	const param = baseParam.replace("--", "");

	if (param === commands.all.name) {
		Object.keys(resources).forEach((key) => {
			setSmartContract(key);
		});
	} else if (param === commands.help.name) {
		console.log("\n\nGeneral:");
		Object.keys(commands).forEach((key) => {
			console.log(`Use --${commands[key].name} to ${commands[key].description}`);
		});
		console.log("\n\nBy Contract:");
		Object.keys(resources).forEach((key) => {
			console.log(`Use: --${key} to send only this contract`);
		});
	} else {
		setSmartContract(param);
	}
};

main();
