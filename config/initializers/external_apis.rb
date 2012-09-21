require 'yaml'
# Load the api.yml config file.
API_CONFIG = YAML.load_file("#{Rails.root}/config/api.yml")[Rails.env]