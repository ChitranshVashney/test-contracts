# Sample Contract

Foundry project of small Solidity `^0.8.20` contracts that each contain an intentional vulnerability. Use them for audit practice, not production.

Solidity **0.8.26** (`foundry.toml`). Built-in overflow checks are on unless a contract uses `unchecked`.

## Contracts

| Contract | Vulnerability |
|---|---|
| `InsecureVault` | Reentrancy — balance is zeroed after the ETH call |
| `UnprotectedToken` | Missing access control on `mint`; `tx.origin` auth |
| `GuessTheSecret` | Predictable on-chain randomness |
| `ReplayableMarket` | Signature replay (no nonce / deadline / chain id) |
| `UnsafeProxy` | Unrestricted `delegatecall` overwrites storage |
| `SpotPricedPool` | Spot-price oracle can be donated against |
| `SilentTokenBank` | ERC-20 return values are ignored |
| `InflationVault` | First-depositor share inflation |
| `UncheckedWallet` | `unchecked` subtraction wraps the balance |

## Commands

```shell
forge build
forge test -vv
forge fmt
```

Deploy locally:

```shell
anvil
forge script script/Deploy.s.sol:DeployScript --rpc-url http://127.0.0.1:8545 --broadcast --private-key <key>
```
