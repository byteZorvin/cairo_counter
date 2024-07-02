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
    use core::starknet::event::EventEmitter;
    use starknet::{ContractAddress, get_caller_address, ClassHash};
    use super::Errors;

    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::upgrades::interface::IUpgradeable;
    use openzeppelin::access::ownable::OwnableComponent;


    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);


    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl OwnableMixinIpl = OwnableComponent::OwnableMixinImpl<ContractState>;


    #[storage]
    struct Storage {
        x: felt252,
        owner: ContractAddress,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnerSet: OwnerSet,
        Incremented: Incremented,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event
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
            self.assert_owner();
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
        fn assert_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, Errors::NOT_OWNER);
        }
    }


    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable.upgrade(new_class_hash);
        }
    }
}
