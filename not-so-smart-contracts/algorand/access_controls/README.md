# Access Controls

Lack of appropriate checks for application calls of type UpdateApplication and DeleteApplication allows attackers to update application’s code or delete an application entirely.

## Description

When an application call is successful, additional operations are executed based on the OnComplete field. If the OnComplete field is set to UpdateApplication the approval and clear programs of the application are replaced with the programs specified in the transaction. Similarly, if the OnComplete field is set to DeleteApplication, application parameters are deleted.
This allows attackers to update or delete the application if proper access controls are not enforced in the application.

## Exploit Scenarios

A stateful contract serves as a liquidity pool for a pair of tokens. Users can deposit the tokens to get the liquidity tokens and can get back their funds with rewards through a burn operation. The contract does not enforce restrictions for UpdateApplication type application calls. Attacker updates the approval program with a malicious program that transfers all assets in the pool to the attacker's address.

## Recommendations

- Set proper access controls and apply various checks before approving applications calls of type UpdateApplication and DeleteApplication.

- Use [Tealer](https://github.com/crytic/tealer) to detect this issue.
