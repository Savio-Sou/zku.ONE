use ethers::types::Address;

pub struct Contracts {
    pub pseudo_DF: Address,
}

pub fn contracts() -> Contracts {
    Contracts {
        pseudo_DF: "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
            .parse::<Address>()
            .expect("fail"),
    }
}
