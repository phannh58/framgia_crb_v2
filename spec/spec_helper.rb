require 'simplecov'
SimpleCov.start 'rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  OmniAuth.config.add_mock(:facebook,
    {provider: :facebook,
    uid: "1234567",
    info: {
      first_name: "Ng",
      name: "test",
      email: "test@gmail.com"},
    credentials: {
      expires_at: Time.now + 1.week,
      token: "1234567"
    }})
  OmniAuth.config.add_mock(:google_oauth2,
    {provider: :google_oauth2,
    uid: "1234567",
    info: {
      first_name: "Ng",
      name: "test",
      email: "test@gmail.com"},
    credentials: {
      expires_at: Time.now + 1.week,
      token: "1234567"
    }})
end
