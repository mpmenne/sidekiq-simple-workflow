lib = File.expand_path("lib", __dir__) # rubocop:disable Gemspec/RequiredRubyVersion
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sidekiq/simple_workflow/version"

Gem::Specification.new do |spec|  # rubocop:disable Rails/BlockLength
  spec.name          = "sidekiq-simple_workflow"
  spec.version       = Sidekiq::SimpleWorkflow::VERSION
  spec.authors       = ["Mike Menne"]
  spec.email         = ["mike@humanagency.com"]

  spec.summary       = "Simple workflows on top of the Sidekiq Batches API"
  spec.description   = "Simple workflows on top of the Sidekiq Batches API"
  spec.homepage      = "https://github.com/humanagency/sidekiq-simple_workflow"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/humanagency/sidekiq-simple_workflow"
    spec.metadata["changelog_uri"] = "https://github.com/humanagency/sidekiq-simple_workflow"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 2.4.0"
  spec.add_dependency "sidekiq-pro", ">= 3.0", "< 6.1"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 2.2.9"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-sidekiq", "~> 3.0"
end
