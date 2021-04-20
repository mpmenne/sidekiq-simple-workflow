RSpec.describe Sidekiq::SimpleWorkflow do
  class TenStepFlow
    include Sidekiq::SimpleWorkflow

    def step_1(_, params)
      ExampleJob.perform_async(params[:id])
    end

    def step_2(_, params)
      ExampleJob.perform_async(params[:second_id])
    end

    def step_3(_, params)
      ExampleJob.perform_async(params[:third_id])
    end

    def step_4(_, params)
      ExampleJob.perform_async(params[:fourth_id])
    end

    def step_5(_, params)
      ExampleJob.perform_async(params[:fifth_id])
    end

    def step_6(_, params)
      ExampleJob.perform_async(params[:sixth_id])
    end

    def step_7(_, params)
      ExampleJob.perform_async(params[:seventh_id])
    end

    def step_8(_, params)
      ExampleJob.perform_async(params[:eigth_id])
    end

    def step_9(_, params)
      ExampleJob.perform_async(params[:ninth_id])
    end

    def step_10(_, params)
      ExampleJob.perform_async(params[:tenth_id])
    end
  end

  class FourStepFlow
    include Sidekiq::SimpleWorkflow

    def step_1(_, params)
      ExampleJob.perform_async(params[:id])
    end

    def step_2(_, params)
      ExampleJob.perform_async(params[:second_id])
    end

    def step_3(_, params)
      ExampleJob.perform_async(params[:third_id])
    end

    def step_4(_, params)
      ExampleJob.perform_async(params[:fourth_id])
    end
  end

  class TwoStepFlow
    include Sidekiq::SimpleWorkflow

    def step_1(_, params)
      ExampleJob.perform_async(params[:first_id])
    end

    def step_2(_, params)
      ExampleJob.perform_async(params[:second_id])
    end
  end

  class OneStepFlow
    include Sidekiq::SimpleWorkflow

    def step_1(_, params)
      ExampleJob.perform_async(params[:id])
    end
  end

  class EmptyFlow
    include Sidekiq::SimpleWorkflow

    def step_1(_, params); end

    def step_2(_, params)
      ExampleJob.perform_async(params[:second_id])
    end
  end

  class ExampleJob
    include Sidekiq::Worker
    def perform(id); end
  end

  it "has a version number" do
    expect(Sidekiq::SimpleWorkflow::VERSION).not_to be nil
  end

  describe "#perform" do
    context "when a batch has multiple steps" do
      it "start will trigger the first batch for the first step" do
        first_id = 1

        OneStepFlow.new.perform(id: first_id)

        expect(ExampleJob).to have_enqueued_sidekiq_job(first_id)
      end
    end

    it "triggers the second step after the first step" do
      first_id = 1
      second_id = 1
      parent_bid = 5
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = { first_id: first_id, second_id: second_id }
      workflow = TwoStepFlow.new

      batch = workflow.step_1_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join
      expect(ExampleJob).to have_enqueued_sidekiq_job(second_id)
    end

    it "triggers as many steps as there are defined step methods" do
      parent_bid = 5
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = { first_id: 1, second_id: 2, third_id: 3, fourth_id: 4 }
      workflow = FourStepFlow.new

      batch = workflow.step_1_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join
      expect(ExampleJob).to have_enqueued_sidekiq_job(params[:second_id])

      batch = workflow.step_2_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join
      expect(ExampleJob).to have_enqueued_sidekiq_job(params[:third_id])
    end

    it "only triggers steps that exist" do
      first_id = 1
      second_id = 1
      parent_bid = 5
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = { first_id: first_id, second_id: second_id }
      workflow = TwoStepFlow.new.perform(params)

      batch = workflow.step_1_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join

      batch = workflow.step_2_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join

      batch = workflow.step_3_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join
    end

    it "only has callbacks for steps that exist" do
      id = 1
      parent_bid = 5
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = {
        first_id: id,
        second_id: id,
        third_id: id,
        fourth_id: id,
        fifth_id: id,
        sixth_id: id,
        seventh_id: id,
        eigth_id: id,
        ninth_id: id,
        tenth_id: id,
      }
      workflow = TwoStepFlow.new.perform(params)

      batch = workflow.step_1_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join

      batch = workflow.step_2_batch(RSpec::Sidekiq::NullStatus, params)
      batch.status.join

      batch = workflow.step_4_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join

      batch = workflow.step_5_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join

      batch = workflow.step_6_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join

      batch = workflow.step_7_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join

      batch = workflow.step_8_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join

      batch = workflow.step_9_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join

      batch = workflow.step_10_batch(RSpec::Sidekiq::NullStatus, params)
      batch&.status&.join
    end

    context "when a step has no workers defined" do
      it "enqueues the NoopWorker" do
        first_id = 1
        second_id = 2
        parent_bid = 3
        options = { first_id: first_id, second_id: second_id }
        allow(RSpec::Sidekiq::NullStatus).
          to receive(:parent_bid).
          and_return(parent_bid)
        batch = RSpec::Sidekiq::NullBatch.new

        workflow = EmptyFlow.new
        batch = workflow.step_1_batch(batch.status, options)
        batch.status.join

        expect(ExampleJob).to have_enqueued_sidekiq_job(second_id)
      end
    end
  end
end
