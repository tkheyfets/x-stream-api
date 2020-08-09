require_relative 'boot'

require "rails"
require "action_controller/railtie"
Bundler.require(*Rails.groups)

module RailsStreamingExample
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.middleware.insert_before 0, Rack::Cors do
	  allow do
	    origins '*'
	    resource '*',
	      headers: :any,
	      methods: [:get, :post, :put, :patch, :delete, :options, :head]
	  end
	end
  end
end
