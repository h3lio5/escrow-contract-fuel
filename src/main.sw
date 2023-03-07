contract;

dep error;
dep escrow;

use error::Error;
use escrow::*;

use std::{
    auth::{
        AuthError,
        msg_sender,
    },
    call_frames::msg_asset_id,
    context::msg_amount,
    token::transfer_to_address,
};

storage {
    escrows: StorageMap<u64, EscrowInstance> = StorageMap {},
    escrow_index: u64 = 0,
}

impl Escrow for Contract {
    #[storage(read, write)]
    fn create(
        receiver: Address,
        requested_asset_id: ContractId,
        requested_asset_amount: u64,
    ) -> u64 {
        let sender: Result<Identity, AuthError> = msg_sender();

        if let Identity::Address(address) = sender.unwrap() {
            let account = EscrowInstance {
                creator: address,
                creator_asset_id: msg_asset_id(),
                creator_asset_amount: msg_amount(),
                receiver,
                requested_asset_id,
                requested_asset_amount,
                status: 0,
            };
            storage.escrows.insert(storage.escrow_index, account);
            storage.escrow_index += 1;
        } else {
            revert(0);
        };
        (storage.escrow_index - 1)
    }

    #[storage(read, write)]
    fn accept(escrow_id: u64) {
        let mut escrow_instance = storage.escrows.get(escrow_id);

        require(escrow_instance.status == 0, Error::IncorrectEscrowState);
        require(escrow_instance.requested_asset_id == msg_asset_id(), Error::IncorrectAssetReceived);
        require(escrow_instance.requested_asset_amount <= msg_amount(), Error::InsufficientAmountReceived);

        let sender: Result<Identity, AuthError> = msg_sender();

        if let Identity::Address(address) = sender.unwrap() {
            require(escrow_instance.receiver == address, Error::IncorrectReceiver);
            escrow_instance.status = 1;
            storage.escrows.insert(escrow_id, escrow_instance);
            transfer_to_address(escrow_instance.requested_asset_amount, escrow_instance.requested_asset_id, escrow_instance.creator);
            transfer_to_address(escrow_instance.creator_asset_amount, escrow_instance.creator_asset_id, escrow_instance.receiver);
        } else {
            revert(0);
        };
    }

    #[storage(read, write)]
    fn revert(escrow_id: u64) {
        let mut escrow_instance = storage.escrows.get(escrow_id);

        require(escrow_instance.status == 0, Error::IncorrectEscrowState);

        let sender: Result<Identity, AuthError> = msg_sender();

        if let Identity::Address(address) = sender.unwrap() {
            require(escrow_instance.creator == address, Error::IncorrectReceiver);
            escrow_instance.status = 2;
            storage.escrows.insert(escrow_id, escrow_instance);
            transfer_to_address(escrow_instance.creator_asset_amount, escrow_instance.creator_asset_id, escrow_instance.creator);
        } else {
            revert(0);
        };
    }
}
