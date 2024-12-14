1 - npm install
2 - npx hardhat test test/AllTests.js
3 - npx hardhat ignition deploy ignition/modules/LoyaltyService.js --network network_id
4 - npx hardhat ignition deploy ignition/modules/PartnerService.js --network network_id

Send contracts to Outsystems
1 - change directory to scripts
2 - npm install
3 - create .env file with
OS_ADMIN=your os user
OS_ADMIN_PASS=your os user pass
OS_HOST=the endpoint to send the contracts to
4 - node admin/set_smart_contract.js -all network_id

Verify contracts
npx hardhat verify --network shape-mainnet 0x31a539F4A4480f6c0dDABBfA3D58e7FB9608d462 0x5d84B43d662CB1787716D4804A6164Efc135FfB6
