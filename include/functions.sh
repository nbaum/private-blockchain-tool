
account_address() {
  cudos-noded keys show $1 -a --keyring-backend test
}

fund_account() {
  cudos-noded add-genesis-account $1 1$GCUDOS
}

make_account() {
  NAME=$1
  shift
  echo "$*" | cudos-noded keys add $NAME --keyring-backend test --recover --output json
  fund_account $(account_address $NAME)
}

make_validator() {
  cudos-noded gentx \
    $1 \
    2$MCUDOS \
    0x0000000000000000000000000000000000000000 \
    $(account_address $1) \
    --min-self-delegation 2000000000000000000000000 \
    --chain-id $CHAIN \
    --keyring-backend test
  jq --arg VALIDATOR_ADDRESS $(account_address account1) \
    '.app_state.gravity.static_val_cosmos_addrs = [$VALIDATOR_ADDRESS]' \
    cudos-data/config/genesis.json | sponge cudos-data/config/genesis.json
}
