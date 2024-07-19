#[starknet::contract]
pub mod Voting {
    use voting::interfaces::IRegistry::IRegistry;
    use voting::base::types::Candidate;
    use voting::interfaces::IVoting::IVoting;


    #[storage]
    struct Storage {
        name: felt252,
        total_votes: u64,
        candidate_votes: LegacyMap<u256, u64>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[constructor]
    fn constructor(ref self: ContractState, name: felt252) {
        self.name.write(name);
    }

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn get_total_votes(self: @ContractState) -> u64 {
            self.total_votes.read()
        }

        fn get_candidate_votes(self: @ContractState, candidate_id: u256) -> u64 {
            self.candidate_votes.read(candidate_id)
        }

        fn vote(ref self: ContractState, candidate_id: u256) {}
    }
}
