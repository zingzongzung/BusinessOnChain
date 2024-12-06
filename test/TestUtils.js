const stringToBytes32 = (text) => {
	// Check if the string is longer than 32 bytes and truncate if necessary
	if (ethers.toUtf8Bytes(text).length > 32) {
		throw new Error("String too long");
	}
	return ethers.encodeBytes32String(text);
};

const bytes32ToString = (bytes) => {
	return ethers.decodeBytes32String(bytes);
};

const printTokenAttrs = async (contract, tokenId) => {
	const attributes = await contract.getTokenAttributes();
	for (let atrIndex = 0; atrIndex < attributes.length; atrIndex++) {
		const attr = attributes[atrIndex];
		const key = bytes32ToString(attr);
		let value = await contract.getTraitValue(tokenId, attr);
		try {
			value = bytes32ToString(await contract.getTraitValue(tokenId, attr));
		} catch (e) {}

		console.log(`${key}: ${value}`);
	}
};

module.exports = { stringToBytes32, bytes32ToString, printTokenAttrs };
