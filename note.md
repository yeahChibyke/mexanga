# key :::: 0x25571828c3f5cdc6f57d124dccd65d1be7ecaa2e

# forge script ./script/DeploySender.s.sol:DeployMexangaSender -vvv --broadcast --account key --sender 0x25571828c3f5cdc6f57d124dccd65d1be7ecaa2e --rpc-url avalancheFuji --sig "run(uint8)" -- 2

# Fuji Contract ::: 0x5Cd2418b813D32171b88Ab4f438d4F9e9a77a20a
# Fuji Hash ::: 0x9002173825957e7198955d25f1f6e7e2d08de5f89470f7f2020d106d7b8d2ad0

# cast send 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846 "transfer(address, uint256)" 0x5Cd2418b813D32171b88Ab4f438d4F9e9a77a20a 1000000000000000000 --rpc-url avalancheFuji --private-key $PRIVATE_KEY 

# Fuji Contract 1 LINK Funding Hash ::: 0x46c971238e12465877ca28c7c2e1acb6640029517673f5ec21157dda70ad38fe

# forge script ./script/DeployReceiver.s.sol:DeployMexangaReceiver -vvv --broadcast --account key --sender 0x25571828c3f5cdc6f57d124dccd65d1be7ecaa2e --rpc-url ethereumSepolia --sig "run(uint8)" -- 0

# ETHEREUM_SEPOLIA_RPC_URL ::: https://eth-sepolia.g.alchemy.com/v2/kFWpPXX8Fjcm4dHGpOeJqGuLnd0wsG30

# Sepolia Contract ::: 0x06AE7a235daAEB7daDFacA4bE39AAb800E1cB9a9
# Sepolia Hash ::: 0x4183a4b6dd070483e37d71d101720c89dbc8b18453c9b746f364bd075184c10d

forge script ./script/Example05.s.sol:SendMessage -vvv --broadcast --rpc-url avalancheFuji --sig "ru
n(address,uint8,address,string,uint8)" -- <BASIC_MESSAGE_SENDER_ADDRESS> 0 <BASIC_MESSAGE_RECEIVER_ADDRESS> "Hello World"
1


