set -e

ROOT=$(dirname $SCRIPT_PATH[0])

source $ROOT/include/functions.sh
source $ROOT/include/variables.sh

# Initialize the chain with default config.
cudos-noded init $NODENAME --chain-id $CHAIN

# Reconfigure the network addresses of the components.
sed -i "/\[api\]/,/\[/ s|^address = .*|address = \"tcp://$ADDRESS:1317\"|" cudos-data/config/app.toml
sed -i "/\[grpc\]/,/\[/ s|^address = .*|address = \"$ADDRESS:9090\"|" cudos-data/config/app.toml
sed -i "/\[grpc-web\]/,/\[/ s|^address = .*|address = \"$ADDRESS:9091\"|" cudos-data/config/app.toml
sed -i "s|^proxy_app = .*|proxy_app = \"$ADDRESS:26658\"|" cudos-data/config/config.toml
sed -i "s|^laddr = .*|laddr = \"tcp://$ADDRESS:26657\"|" cudos-data/config/config.toml
sed -i "s|^pprof_laddr = .*|pprof_laddr = \"$ADDRESS:6060\"|" cudos-data/config/config.toml
sed -i "/\[p2p\]/,/\[/ s|^laddr = .*|laddr = \"tcp://$ADDRESS:26656\"|" cudos-data/config/config.toml
sed -i "s|^prometheus_listen_addr = .*|prometheus_listen_addr = \"$ADDRESS:26660\"|" cudos-data/config/config.toml

# Make the API available in browsers.
# Only necessary if you're going to be using a browser app with this chain.
sed -i "s/cors_allowed_origins = \[\]/cors_allowed_origins = \[\"\*\"\]/" cudos-data/config/config.toml
sed -i "s/enabled-unsafe-cors = false/enabled-unsafe-cors = true/" cudos-data/config/app.toml

# Set the minimum gas price to 0.
sed -i "s/minimum-gas-prices = \"\"/minimum-gas-prices = \"0$TOKEN\"/" cudos-data/config/app.toml

# Enable the REST API.
sed -i "/\[api\]/,/\[/ s/enable = false/enable = true/" cudos-data/config/app.toml

# Reduce the commit timeout so local testing can go faster.
sed -i "s/^timeout_commit = .*/timeout_commit = \"1s\"/" cudos-data/config/config.toml

# Apply various customizations to the genesis block.
jq -f $ROOT/include/genesis.jq cudos-data/config/genesis.json | sponge cudos-data/config/genesis.json

# Make the "default" account. This is used as a validator.
make_account account1 "ordinary witness such toddler tag mouse helmet perfect venue eyebrow upgrade rabbit"

# Make a validator from the default account.
make_validator account1

# Add 1gigacudos to an account of your choosing.
fund_account "cudos1genudzpvqe2t9k64xwueua35a8kfvl3fc6uc62"

# Put the accounts above
cudos-noded collect-gentxs
