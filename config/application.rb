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
    # ENV["tp_auth_user"] = Rails.env.tp_auth_user
    # ENV["tp_auth_pass"] = Rails.env.tp_auth_pass
    # ENV["tp_auth_token"] = Rails.env.tp_auth_token
    # ENV["harvest_auth_token"] = Rails.env.harvest_auth_token
    # ENV["slack_auth_token"] = Rails.env.slack_auth_token
    # YAML.load(File.open(dev))["defaults"].each do |key,value|
    #   ENV[key.to_s] = value
    # end
    config.allow_concurrency = true
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths  += [Rails.root.join('lib').to_s]
  end
end
