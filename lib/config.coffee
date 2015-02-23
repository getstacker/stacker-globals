module.exports =
  # Name of loaded stacker file
  # Set by cli options or searches local dir for 'stacker.[yaml|yml|json]'
  stackerfile: null
  # Contents of stackerfile
  stacker: {}

  # Current environment config.
  config: {}

  # Instance of Config.
  # Contains all config values, including multiple environments.
  _config: null
