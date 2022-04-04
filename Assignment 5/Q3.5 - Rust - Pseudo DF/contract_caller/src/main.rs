// extern crate ethers;
use ethers::middleware::SignerMiddleware;
use ethers::providers::{Http, Provider};
use ethers::signers::LocalWallet;
use std::convert::TryFrom;
mod contracts;
mod pseudo_DF;
use dotenv::dotenv;
// use std::env;

#[tokio::main]
async fn main() {
    println!("\nPseudo Dark Forest Caller Starts!\n");
    dotenv().ok();

    let pk = dotenv::var("PRIVATE_KEY").unwrap();
    let wallet: LocalWallet = pk.parse().expect("fail parse");
    // println!("{}", pk);
    let url = dotenv::var("RPC_URL").unwrap();

    // connect provider
    let provider_service = Provider::<Http>::try_from(url).expect("failed");

    let provider = SignerMiddleware::new(provider_service, wallet);

    // connect contracts
    let [pseudo_DF_contract] = contracts::get_contracts(&provider);
    println!("contracts connected");

    // Make triangle move
    pseudo_DF::run(pseudo_DF_contract).await;

    println!("Triangle move made.")
}
