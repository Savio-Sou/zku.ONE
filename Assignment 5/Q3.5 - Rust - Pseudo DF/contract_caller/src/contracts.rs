use ethers::middleware::SignerMiddleware;
use ethers::{
    abi::Abi,
    contract::Contract,
    providers::{Http, Provider},
    signers::LocalWallet,
    types::Address,
};
#[path = "./utils/abis/abis.rs"]
mod abis;
#[path = "./utils/addresses.rs"]
mod addresses;

fn get_pseudo_DF(
    provider: &SignerMiddleware<Provider<Http>, LocalWallet>,
) -> Contract<&SignerMiddleware<Provider<Http>, LocalWallet>> {
    let abi_original: String = abis::pseudo_DF();
    let abi: Abi = serde_json::from_str(&abi_original).expect("failed");
    let address: Address = (addresses::contracts()).pseudo_DF;
    let contract = Contract::new(address, abi, provider);
    return contract;
}

pub fn get_contracts(
    provider: &SignerMiddleware<Provider<Http>, LocalWallet>,
) -> [Contract<&SignerMiddleware<Provider<Http>, LocalWallet>>; 1] {
    let static_provider = &provider;
    let pseudo_DF = get_pseudo_DF(static_provider);
    return [pseudo_DF];
}
