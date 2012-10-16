# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_local_tax'
  s.version     = '1.1.2'
  s.summary     = 'Local tax calculation for Spree Commerce'
  s.description = 'Local tax calculation (i.e. state based for US tax requirements) for Spree Commerce.' +
                  'ability to include/exclude shipping, promotions, etc from tax calculation'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'Michael Bianco'
  s.email     = 'info@cliffsidedev.com'
  s.homepage  = 'http://mabblog.com/'

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.1'
  s.add_dependency 'ruport'
  s.add_dependency 'spree_advanced_reporting'

  # this is for the local tax reports
  # you can rip out the reporting and safely remove this dependency in a fork
  # s.add_dependency 'spree_advanced_reporting'

  s.add_development_dependency 'rspec-rails', '~> 2.9'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'ffaker'
end
