source 'http://rubygems.org'

group :test do
  gem 'ffaker'
  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'rspec-rails', '~> 2.9'
  gem 'factory_girl', '~> 2.6.4'
  gem 'capybara', '1.0.1'
  gem 'sqlite3'
  
  if RUBY_PLATFORM.downcase.include? "darwin"
    gem 'rb-fsevent'
    gem 'growl'
  end
end

gem 'spree', '~> 1.1.3'

gemspec
