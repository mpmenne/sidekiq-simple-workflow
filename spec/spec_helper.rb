require "bundler/setup"
require "sidekiq/simple_workflow"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  require "sidekiq"
  require "active_support/all"
  require "rspec-sidekiq"
  require "pry"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
