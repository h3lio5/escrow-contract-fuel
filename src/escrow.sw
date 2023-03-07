library escrow;

pub struct EscrowInstance {
    creator: Address,
    receiver: Address,
    creator_asset_id: ContractId,
    creator_asset_amount: u64,
    requested_asset_id: ContractId,
    requested_asset_amount: u64,
    status: u64, // 0: not init, 1: completed, 2: reverted
}

abi Escrow {
    #[storage(read, write)]
    fn create(receiver: Address, requested_asset_id: ContractId, requested_asset_amount: u64) -> u64;
    #[storage(read, write)]
    fn accept(escrow_id: u64);
    #[storage(read, write)]
    fn revert(escrow_id: u64);
}
