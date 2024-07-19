use voting::base::types::Candidate;

#[starknet::interface]
pub trait IRegistry<TContractState> {
    fn get_candidate(self: @TContractState, candidate_id: u256) -> Candidate;
    fn register_candidate(ref self: TContractState, fullname: felt252, party: felt252);
    fn delete_candidate(ref self: TContractState, candidate_id: u256);
}
