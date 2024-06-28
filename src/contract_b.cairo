#[starknet::interface]
trait IContractB<TState> {
    fn increment_a(ref self: TState);
}

#[starknet::contract]
mod ContractB {
    use cairo_counter::contract_a::IContractADispatcherTrait;
    use core::starknet::storage::StoragePointerWriteAccess;
    use starknet::ContractAddress;
    use super::IContractB;
    use cairo_counter::contract_a::IContractADispatcher;


    #[storage]
    struct Storage {
        contract_a: ContractAddress
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
    }

    #[generate_trait]
    impl RandomImplementation of RandomTrait {
        fn get_dispatcher(self: @ContractState) -> IContractADispatcher {
            let dispatcher = IContractADispatcher { contract_address: self.contract_a.read() };
            return dispatcher;
        }
    }
}
