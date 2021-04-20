require "sidekiq/worker"

module Sidekiq
  module SimpleWorkflow
    class NoOpWorker
      include Sidekiq::Worker

      def perform
        true
        # intentionally left blank
      end
    end
  end
end
