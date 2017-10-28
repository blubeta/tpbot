require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tpbot
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    if Rails.env == 'development'
      config_yml = File.join(Rails.root, 'config', 'config.yml')
      YAML.load(File.open(config_yml))["defaults"].each do |key,value|
        ENV[key.to_s] = value
        p ENV
      end
    end
    config.allow_concurrency = true
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths  += [Rails.root.join('lib').to_s]
  end
end
