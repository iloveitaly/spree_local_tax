# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'ffaker'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories defined in spree_core
require 'spree/core/testing_support/factories'
require 'spree/core/url_helpers'

Dir[File.join(File.dirname(__FILE__), "factories/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::Core::UrlHelpers
  config.mock_with :rspec
  config.use_transactional_fixtures = true
end
