require "sidekiq/simple_workflow/no_op_worker"
require "sidekiq/simple_workflow/version"
require "sidekiq-pro"
require "sidekiq/worker"

module Sidekiq
  module SimpleWorkflow
    class Error < StandardError; end
    attr_accessor :options

    def perform(*args)
      @options = args.first
      batch = Sidekiq::Batch.new
      batch.jobs do
        step_1_batch(batch.status, @options)
      end
      batch
    end

    (1..10).each do |step_number|
      define_method("step_#{step_number}_batch") do |status, options|
        if respond_to? step_method_name(step_number)
          overall = Sidekiq::Batch.new(status.parent_bid)
          next_step_method = step_method_name(step_number + 1)
          if respond_to? next_step_method

            callback = "#{self.class}##{next_step_method}"
            overall.on(:complete, callback, options)
          end
          overall.jobs do
            send(step_method_name(step_number), overall.status, options)
            NoOpWorker.perform_async
          end
          overall
        end
      end
    end

    private

    def callback_method(number)
      "#{self.class}#step_#{number}_batch"
    end

    def step_method_name(number)
      "step_#{number}".to_sym
    end
  end
end
