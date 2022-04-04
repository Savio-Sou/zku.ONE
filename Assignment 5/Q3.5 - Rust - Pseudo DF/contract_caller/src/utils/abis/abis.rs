#[path = "./PseudoDFABI.rs"]
mod pseudo_DF;

pub fn pseudo_DF() -> String {
    return pseudo_DF::pseudo_DF_abi();
}