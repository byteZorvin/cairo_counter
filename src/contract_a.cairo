use starknet::ContractAddress;

pub mod Errors {
    pub const NOT_OWNER: felt252 = 'Not the owner';
}

#[starknet::interface]
pub trait IContractA<TContractState> {
    fn increment_from_b(ref self: TContractState);
    fn get_x(self: @TContractState) -> felt252;
    fn set_new_owner(ref self: TContractState, new_owner: ContractAddress);
    fn get_current_owner(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod ContractA {
    use cairo_counter::contract_a::IContractA;
    // use core::starknet::storage::StoragePointerReadAccess;
    use core::starknet::event::EventEmitter;
    use starknet::{ContractAddress, get_caller_address};
    use super::Errors;

    #[storage]
    struct Storage {
        x: felt252,
        owner: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnerSet: OwnerSet,
        Incremented: Incremented
    }


    #[derive(Drop, starknet::Event)]
    struct OwnerSet {
        #[key]
        new_owner: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct Incremented {
        new_value: felt252
    }


    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
        self.emit(OwnerSet { new_owner: owner });
    }

    impl ContractA of super::IContractA<ContractState> {
        fn increment_from_b(ref self: ContractState) {
            self.assert_only_owner();
            self.x.write(self.x.read() + 1);
            self.emit(Incremented { new_value: self.x.read() });
        }

        fn get_x(self: @ContractState) -> felt252 {
            return self.x.read();
        }

        fn set_new_owner(ref self: ContractState, new_owner: ContractAddress) {
            self.owner.write(new_owner);
        }

        fn get_current_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl InteralImpl of InternalTrait {
        fn assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, Errors::NOT_OWNER);
        }
    }
}
