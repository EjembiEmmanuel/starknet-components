#[starknet::contract]
pub mod Voting {
    use voting::interfaces::IRegistry::IRegistry;
    use voting::base::types::Candidate;
    use voting::interfaces::IVoting::IVoting;
    use voting::registry::registry::RegistryComponent;

    component!(path: RegistryComponent, storage: registry, event: RegisterEvent);

    #[abi(embed_v0)]
    impl RegistryImpl = RegistryComponent::Registry<ContractState>;

    #[storage]
    struct Storage {
        name: felt252,
        total_votes: u64,
        candidate_votes: LegacyMap<u256, u64>,
        #[substorage(v0)]
        registry: RegistryComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RegisterEvent: RegistryComponent::Event
    }

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

        fn vote(ref self: ContractState, candidate_id: u256) {
            let candidate = self.registry.get_candidate(candidate_id);
            assert(candidate.is_registered, 'Candidate not registered');

            let candidate_votes = self.candidate_votes.read(candidate_id);
            self.candidate_votes.write(candidate_id, candidate_votes + 1);

            let total_votes = self.total_votes.read();
            self.total_votes.write(total_votes + 1)
        }
    }
}
