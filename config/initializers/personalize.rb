require 'yaml'
# Load personalize configuration
PERSONALIZE_CONFIG = YAML.load_file("#{Rails.root}/config/personalize.yml")[Rails.env]