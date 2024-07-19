#[starknet::contract]
pub mod Voting {
    use voting::interfaces::IRegistry::IRegistry;
    use voting::base::types::Candidate;
    use voting::interfaces::IVoting::IVoting;

    // bring component into module context
    use voting::registry::registry::RegistryComponent;
    use voting::registry::registry::RegistryComponent::InternalTrait;

    // declare component
    component!(path: RegistryComponent, storage: registry, event: RegistryEvent);

    // implement component external functions
    #[abi(embed_v0)]
    impl RegistryImpl = RegistryComponent::Registry<ContractState>;

    // implement component internal functions
    impl RegistryInternalImpl = RegistryComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        name: felt252,
        total_votes: u64,
        candidate_votes: LegacyMap<u256, u64>,
        // define component storage
        #[substorage(v0)]
        registry: RegistryComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        // define component event
        RegistryEvent: RegistryComponent::Event
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
            let is_registered = self.registry._is_registered(candidate_id);
            assert(is_registered, 'Candidate not registered');

            let candidate_votes = self.candidate_votes.read(candidate_id);
            self.candidate_votes.write(candidate_id, candidate_votes + 1);

            let total_votes = self.total_votes.read();
            self.total_votes.write(total_votes + 1)
        }
    }
}
