# OWNER-vault Clarity Contract

## Overview

OWNER-vault is a production-style Clarity smart contract for the Stacks blockchain.  
It provides secure storage and management of a single unsigned integer value, with robust access control and auditability features.

## Features

- **Secure Value Storage:** Stores a single unsigned integer (`uint`) on-chain.
- **Owner-Only Updates:** Only the contract owner can update the stored value.
- **Read-Only Getter:** Anyone can read the current value.
- **Historical Log:** Maintains a log of all value changes, including setter and event ID.
- **Ownership Transfer:** Owner can transfer contract ownership to another principal.
- **Value Validation:** Enforces configurable minimum and maximum value constraints.
- **Structured Error Codes:** Predictable error responses for common failure cases.

## Contract Functions

| Function                | Type           | Description                                      |
|-------------------------|----------------|--------------------------------------------------|
| `set-value`             | public         | Set a new value (owner only, with validation)    |
| `get-value`             | read-only      | Get the current stored value                     |
| `get-event`             | read-only      | Get historical value change by event ID          |
| `transfer-ownership`    | public         | Transfer contract ownership                      |
| `get-owner`             | read-only      | Get current contract owner                       |

## Error Codes

- `ERR_UNAUTHORIZED` (`u100`): Caller is not the contract owner
- `ERR_VALUE_TOO_LARGE` (`u101`): Value exceeds allowed maximum
- `ERR_VALUE_TOO_SMALL` (`u102`): Value is below allowed minimum

## Usage

Deploy the contract using [Clarinet](https://docs.stacks.co/docs/clarinet/overview/) or your preferred Stacks development tool.

### Example: Set Value

```clarity
(contract-call? .OWNER-vault set-value u123)
```

### Example: Get Value

```clarity
(contract-call? .OWNER-vault get-value)
```

### Example: Transfer Ownership

```clarity
(contract-call? .OWNER-vault transfer-ownership 'ST123...')
```

## Extending

You can extend this contract with:
- Upgradeable storage patterns
- Multiple named variables
- Event pagination helpers
- Admin roles and permissions
- On-chain payments for value updates
