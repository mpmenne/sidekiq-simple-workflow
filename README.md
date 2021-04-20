# Sidekiq::SimpleWorkflow
This is a *very simple* wrapper around the [Sidekiq Batches API](https://github.com/mperham/sidekiq/wiki/Batches).

Where as other gems recreate the full power of creating complex, fully parallel workflows, this gem does the opposite.  It offers up to 10 steps that are run sequentially.  Each step can have a very large number of parallel jobs.  Only once all of the parallel jobs for a step have been completed, the call back for the next step will be triggered.

Here is an example:
```
class SimpleWorkflow
  include Sidekiq::SimpleWorkflow

  def step_1(status, options)
    SomeJob.perform_async
    SomeOtherJob.perform_async
  end

  def step_2(status, options)
    ThenRunThisJob.perform_async
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-simple_workflow'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-simple_workflow

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sidekiq-simple_workflow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::SimpleWorkflow project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sidekiq-simple_workflow/blob/master/CODE_OF_CONDUCT.md).
