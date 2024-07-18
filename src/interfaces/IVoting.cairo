use voting::base::types::Candidate;

#[starknet::interface]
pub trait IVoting<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_total_votes(self: @TContractState) -> u64;
    fn get_candidate_votes(self: @TContractState, candidate_id: u256) -> u64;
    fn vote(ref self: TContractState, candidate_id: u256);
}
