require "vcr"

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/vcr"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.default_cassette_options = { match_requests_on: [:method, :host], record: :new_episodes }
  config.ignore_hosts "codeclimate.com"
end
