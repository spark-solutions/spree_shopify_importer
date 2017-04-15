# Run Coverage report
require 'simplecov'
SimpleCov.start 'rails'

# Configure Rails Environment
ENV['RAILS_ENV'] ||= 'test'

begin
  require File.expand_path('../dummy/config/environment', __FILE__)
rescue LoadError
  puts 'Could not load dummy application. Please ensure you have run `bundle exec rake test_app`'
  exit
end

require 'rspec/rails'
require 'ffaker'
require 'pry'


RSpec.configure do |config|
  config.mock_with :rspec
  config.color = true
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = "random"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }
