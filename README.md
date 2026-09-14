# Sample Contract

Foundry project with a single Solidity `^0.8.20` contract that contains several intentional vulnerabilities. Audit practice only — do not deploy this as a real bank.

Compiled with **0.8.26**.

## `SampleContract`

| Function | Vulnerability |
|---|---|
| `withdraw` | Reentrancy — balance is zeroed after the ETH call |
| `mint` | Missing access control |
| `changeOwner` | `tx.origin` authentication |
| `play` | Predictable on-chain randomness |
| `transfer` | `unchecked` subtraction wraps the balance |
| `claimWithSignature` | Signature replay (no nonce / deadline / chain id) |

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
