use ethers::{
    contract::Contract,
    middleware::SignerMiddleware,
    providers::{Http, Provider},
    signers::LocalWallet,
    types::Address,
};
use std::fmt;

pub async fn run(
    pseudo_DF: Contract<&SignerMiddleware<Provider<Http>, LocalWallet>>,
) {
    pseudo_DF
    .method::<>()
    .expect("fail method")
    .call()
    .await
    .expect("fail wait");
}