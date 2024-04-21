# scaling-ethereum-2024
# MemecoinCooker
MemecoinCooker facilitates the creation of memecoins through a two-step process.

Initially, it deploys the Memecoin contract via the Factory contract, specifying key details such as the memecoin's owner, name, symbol, and total supply. The memecoin adheres to the ERC20 standard without any additional features. Following deployment, the MemecoinCooker contract initially possesses 100% of the created coin's supply.

The second step allows the launch of the memecoin on the desired exchange, with Uniswap v2 being the current supported platform. During token launch, the memecoin's creator must provide its address along with an initial team distribution. This initial distribution is restricted to a maximum of 10% of the total supply. Additionally, the creator must supply an amount of ETH, which contributes to establishing an initial price for the memecoin. Upon launch, a liquidity pool is created, and the Liquidity token is locked for a duration of 30 days.

The contracts are deployed on Arbitrum Sepolia testnet and Ethereum Sepolia testnet under the following addresses :
- Arbitrum Sepolia : 0x1d1Cc545250fff3d11ffB52005ffc450FD0cDE3A
- Ethereum Sepolia : 0x147bb33932f172c5c83e1124896a65fd04dbad61
