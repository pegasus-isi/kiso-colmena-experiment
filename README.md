# Getting Started

## Prerequisites

```sh
pip install kiso
# Install the resource provider specific dependencies you want to use
pip install kiso[vagrant]
```

## Running the experiment

Place any required credentials files in the `secrets` directory.

## Running the experiment

```sh
# Provision and setup the resources
kiso up --output ./output

# Run the experiments defined in the experiment configuration YAML file
kiso run --output ./output

# Destroy the provisioned resources
kiso down --output ./output

# Pegasus workflow submit directories will be placed in the output directory at the end of the experiment. The submit directories will also have a statistics directory with the pegasus-statistics output.
# Outputs defined in the experiment configuration will be placed to the destination specified in the experiment configuration.
```

# References

- [Pegasus Workflow Management System](https://pegasus.isi.edu)
- [EnOSlib](https://discovery.gitlabpages.inria.fr/enoslib/)
- [Chameleon Cloud](https://www.chameleoncloud.org)
- [FABRIC](https://portal.fabric-testbed.net)

# Acknowledgements

Kiso is funded by National Science Foundation (NSF) under award [2403051](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2403051).
