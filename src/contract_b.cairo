use starknet::ClassHash;

#[starknet::interface]
trait IContractB<TState> {
    fn increment_a(ref self: TState);
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
}

#[starknet::contract]
mod ContractB {
    use cairo_counter::contract_a::IContractADispatcherTrait;
    // use core::starknet::storage::StoragePointerWriteAccess;
    use starknet::{ContractAddress, ClassHash, SyscallResultTrait};
    use super::IContractB;
    use cairo_counter::contract_a::IContractADispatcher;


    #[storage]
    struct Storage {
        contract_a: ContractAddress
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Upgraded: Upgraded
    }

    #[derive(Drop, starknet::Event)]
    struct Upgraded {
        #[key]
        class_hash: ClassHash
    }


    #[constructor]
    fn constructor(ref self: ContractState, contract_b: ContractAddress) {
        self.contract_a.write(contract_b);
    }

    #[abi(embed_v0)]
    impl ContractBImplementation of IContractB<ContractState> {
        fn increment_a(ref self: ContractState) {
            let dispatcher = self.get_dispatcher();
            dispatcher.increment_from_b();
        }

        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            starknet::syscalls::replace_class_syscall(new_class_hash).unwrap_syscall();
            self.emit(Upgraded { class_hash: new_class_hash });
        }
    }

    #[generate_trait]
    impl RandomImplementation of RandomTrait {
        fn get_dispatcher(self: @ContractState) -> IContractADispatcher {
            let dispatcher = IContractADispatcher { contract_address: self.contract_a.read() };
            return dispatcher;
        }
    }
}
