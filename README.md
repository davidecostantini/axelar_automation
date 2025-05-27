## Deploy a node

This is a simple script to deploy an axelar node on kubernetes with an helm chart
It's customisable with variables in `values.yaml` and uses an InitContainer to configure the pod but currently it's just a basic script and is not production grade as it doesn't supports aspects like persistent volumes, network snapshot, etc...
An example of a K8S configuration for a persistent volume can be found in the cluster directory

```
# To deploy a node just run
helm install axelar helm/node
```

## Phases to deploy a Validator

### 1) Configuration

#### Binaries
- tofnd (gRPC wrapper for tofn crypt lib)
- axelar

#### Directories
root_directory="$HOME/.axelar" or root_directory="$HOME/.axelar_testnet"

vald_directory="${root_directory}/vald"
tofnd_directory="${root_directory}/tofnd"
bin_directory="$root_directory/bin"
logs_directory="$root_directory/logs"
config_directory="$root_directory/config"

#### Home directory tree (* is neede by validator)
```
.axelar
├── bin
│   ├── axelard -> /Users/gus/.axelar/bin/axelard-vx.y.z
│   ├── axelard-vx.y.z
│   ├── tofnd -> /Users/gus/.axelar/bin/tofnd-va.b.c  *
│   └── tofnd-va.b.c  *
├── config
│   ├── app.toml
│   ├── config.toml
│   ├── genesis.json
│   ├── node_key.json *
│   ├── priv_validator_key.json *
│   ├── priv_validator_state.json *
│   └── seeds.toml
├── data
├── logs
├── tofnd *
└── vald *
    └── state.json
```

#### Env vars
{AXELARD_HOME} -> Axelar home dir
{VALIDATOR_ADDR} -> validator address


### 2) Configure keys

- Backup private key ${AXELARD_HOME}/config/priv_validator_key.json
- Create and backup `validator` and `broadcaster` account
axelard keys add validator --home $AXELARD_HOME
axelard keys add broadcaster --home $AXELARD_HOME
- Create and backup tofnd account
tofnd -m create -d ${AXELARD_HOME}/tofnd

NOTE: also backup mnemonics for these 3 accounts


### 3) Launch validator

- Launch tofnd
```
$AXELARD_HOME/bin/tofnd -m existing -d $AXELARD_HOME/tofnd >> $AXELARD_HOME/logs/tofnd.log 2>&1
```

- launch vald
```
$AXELARD_HOME/bin/axelard vald-start --validator-addr {VALOPER_ADDR} --chain-id $AXELARD_CHAIN_ID --log_level debug --home $AXELARD_HOME
```


- To get the `valoper` and `broadcaster` address:
```
$AXELARD_HOME/bin/axelard keys show validator --bech val -a --home $AXELARD_HOME

$AXELARD_HOME/bin/axelard keys show broadcaster -a --home $AXELARD_HOME
```


### 3) Register broadcast proxy

After funding both validator and broadcaster accounts registrer the account
```
$AXELARD_HOME/bin/axelard tx snapshot register-proxy {BROADCASTER_ADDR} --from validator --chain-id $AXELARD_CHAIN_ID --home $AXELARD_HOME --gas auto --gas-adjustment 1.4
```

To check the registration
```
$AXELARD_HOME/bin/axelard q snapshot proxy {VALOPER_ADDR}
```



# Improvements/notes

- Use containers that already contains all dependencies
- Slow to deploy a node if using init container (to pull snapshot)
- Need to automate snapshot generation (k8s snapshot/pvc resource and use cloud services GCP Filestore, AWS EFS)
- Do not rely or limit 3rd party dependencies (binaries, docker images, snapshot, genesis)
- Secrets management (keys, mnemonic)
