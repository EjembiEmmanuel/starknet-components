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
