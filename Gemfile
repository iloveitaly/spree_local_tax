source 'http://rubygems.org'
gemspec

group :test do
  if RUBY_PLATFORM.downcase.include? "darwin"
    gem 'guard-rspec'
    gem 'rb-fsevent'
    gem 'growl'
  end
end

# specific to my dev setup
gem 'ruport', :git => 'https://github.com/iloveitaly/ruport.git', :branch => 'wicked-pdf'
gem 'spree_advanced_reporting', :git => 'https://github.com/iloveitaly/spree_advanced_reporting.git'

gem 'spree', '~> 1.2'
