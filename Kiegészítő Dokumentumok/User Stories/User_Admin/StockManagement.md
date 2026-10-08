# Stock Management

**Requirements:** L10, K17
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/StockManagement.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/StockManagement.feature)

## User Story
As an administrator
I want to keep track of the stock, be warned about items running low and decide on the workers' supply requests
So that the bar never runs out during the night

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A stock item has a name, category, quantity, unit and minimum quantity; names are unique
* Items below their minimum are flagged
* Approving a supply request takes the quantity from the stock
* Approving warns when the item falls below its minimum
* A request larger than the stock cannot be approved
* A request can be rejected without changing the stock
