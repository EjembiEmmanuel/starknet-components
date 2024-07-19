# Starknet Components

## What are Components?

Components are add-ons that encapsulate reusable logic, storage, and events that can be incorporated in multiple contracts.

`Note:` unlike contracts, components cannot be declared or deployed.

### Components can consist of:

- Storage variables
- Events
- External and Internal functions

## Creating Components

A component can be created by defining it in its own module and decorating it with the `#[starknet:component]` attribute. Within this module, you can declare a `Storage` struct and an `Event` enum, as you would in contracts.

Next, define the component interface with function signatures for external access by declaring a trait with the `#[starknet::interface]` attribute, similar to contracts.

The implementation the component's external logic is done in an `impl` block decorated with the `#[embeddable_as(name)]` attribute, typically for the component's interface trait. Internal functions can be defined without the `#[embeddable_as(name)]` attribute, making them accessible only within the contract and not externally.

## Voting Contract

```Rust
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

```

## Registry Component

```Rust
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

```
