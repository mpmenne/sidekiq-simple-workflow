require "sidekiq/simple_workflow/no_op_worker"
require "sidekiq/simple_workflow/version"
require "sidekiq-pro"
require "sidekiq/worker"

module Sidekiq
  module SimpleWorkflow
    class Error < StandardError; end
    attr_accessor :options

    # rename to perform_async
    def start_workflow(*args)
      @options = args.first
      parent_batch = Sidekiq::Batch.new
      parent_batch.description = "#{self.class} Parent Batch"
      parent_batch.jobs do
        step_1_batch(parent_batch.status, args.first)
      end
      parent_batch
    end

    (1..10).each do |step_number|
      define_method("step_#{step_number}_batch") do |status, options|
        if respond_to? step_method_name(step_number)
          step_batch = nil
          original_batch = Sidekiq::Batch.new(status.parent_bid)
          original_batch.jobs do
            step_batch = Sidekiq::Batch.new
            step_batch.description = "#{self.class} step_#{step_number} Batch"
            next_step_method = step_method_name(step_number + 1)
            if respond_to? next_step_method

              callback = callback_method(step_number + 1)
              step_batch.on(:success, callback, options)
            end
            step_batch.jobs do
              send(step_method_name(step_number), status, options)
              NoOpWorker.perform_async
            end
          end
          if defined?(Sidekiq::Testing) && Sidekiq::Testing.enabled?
            step_batch.status.join
          end
          step_batch
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
