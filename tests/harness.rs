use fuels::{prelude::*, tx::ContractId};

// Load abi from json
abigen!(Contract(
    name = "Escrow",
    abi = "out/debug/escrow_contract-abi.json"
));

abigen!(Contract(
    name = "Asset",
    abi = "tests/artifacts/asset/out/debug/asset-abi.json"
));

async fn get_contract_instance() -> (Escrow, ContractId) {
    // Launch a local network and deploy the contract
    let mut wallets = launch_custom_provider_and_get_wallets(
        WalletsConfig::new(
            Some(1),             /* Single wallet */
            Some(1),             /* Single coin (UTXO) */
            Some(1_000_000_000), /* Amount per coin */
        ),
        None,
        None,
    )
    .await;
    let wallet = wallets.pop().unwrap();

    let id = Contract::deploy(
        "./out/debug/escrow-contract.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::with_storage_path(Some(
            "./out/debug/escrow-contract-storage_slots.json".to_string(),
        )),
    )
    .await
    .unwrap();

    let instance = Escrow::new(id.clone(), wallet);

    (instance, id.into())
}

#[tokio::test]
async fn can_get_contract_id() {
    let (_instance, _id) = get_contract_instance().await;

    // Now you have an instance of your contract you can use to test each function
}
