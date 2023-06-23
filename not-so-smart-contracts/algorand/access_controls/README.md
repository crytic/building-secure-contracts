# Access Controls

Inadequate checks for application calls of type UpdateApplication and DeleteApplication can allow attackers to alter an application's code or delete it entirely.

## Description

When an application call is successful, further operations are carried out based on the OnComplete field. If the OnComplete field is set to UpdateApplication, the approval and clear programs of the application get replaced with the programs specified in the transaction. Likewise, if the OnComplete field is set to DeleteApplication, the application parameters get deleted. This can let attackers update or delete the application if proper access controls are not in place.

## Exploit Scenarios

A stateful contract functions as a liquidity pool for two tokens. Users can deposit these tokens to acquire liquidity tokens and can retrieve their funds along with rewards via a burn operation. The contract, however, does not enforce any restrictions for UpdateApplication type application calls. An attacker can update the approval program with a malicious program that transfers all the assets in the pool to their address.

## Recommendations

- Implement appropriate access controls and conduct various checks before approving application calls of type UpdateApplication and DeleteApplication.

- Utilize [Tealer](https://github.com/crytic/tealer) to identify this issue.
