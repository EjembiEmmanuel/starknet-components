
#[starknet::component]
pub mod RegistryComponent {
    use voting::base::types::Candidate;
    use voting::interfaces::IRegistry::IRegistry;

    #[storage]
    struct Storage {
        candidates: LegacyMap<u256, Candidate>,
        last_registered_candidate_id: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CandidateRegistered: CandidateRegistered
    }

    #[derive(Drop, starknet::Event)]
    pub struct CandidateRegistered {
        candidate: Candidate,
        candidate_id: u256
    }

    #[embeddable_as(Registry)]
    impl RegistryImpl<
        TContractState, +HasComponent<TContractState>
    > of IRegistry<ComponentState<TContractState>> {
        fn get_candidate(self: @ComponentState<TContractState>, candidate_id: u256) -> Candidate {
            self.candidates.read(candidate_id)
        }

        fn register_candidate(
            ref self: ComponentState<TContractState>, fullname: felt252, party: felt252
        ) {
            let candidate = Candidate { fullname, party, is_registered: true };
            let last_registered_candidate_id = self.last_registered_candidate_id.read();
            let candidate_id = last_registered_candidate_id + 1;

            self.candidates.write(candidate_id, candidate.clone());
            self.last_registered_candidate_id.write(candidate_id);

            self.emit(CandidateRegistered { candidate, candidate_id });
        }

        fn delete_candidate(ref self: ComponentState<TContractState>, candidate_id: u256) {
            assert(self._is_registered(candidate_id), 'Candidate not registered');

            let candidate = Candidate { fullname: '', party: '', is_registered: false };

            self.candidates.write(candidate_id, candidate)
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn _is_registered(self: @ComponentState<TContractState>, candidate_id: u256) -> bool {
            let candidate: Candidate = self.candidates.read(candidate_id);
            let is_registered: bool = candidate.is_registered;
            is_registered
        }
    }
}