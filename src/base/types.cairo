#[derive(Drop, Serde, starknet::Store, Clone)]
pub struct Candidate {
    pub fullname: felt252,
    pub party: felt252,
    pub is_registered: bool,
}
