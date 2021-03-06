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
    context "when a batch has a single step" do
      it "the first batch has a description that matches the class" do
        first_id = 1

        batch = OneStepFlow.new.start_workflow(id: first_id)

        expect(batch.description).to eq("OneStepFlow Parent Batch")
      end

      it "start will trigger the first batch for the first step" do
        job_stub = create_job_stub
        first_id = 1

        batch = OneStepFlow.new.start_workflow(id: first_id)

        expect(job_stub).to have_received(:perform_async).with(first_id)
      end

      it "the first batch has a description" do
        id = 1

        params = { id: id }
        workflow = OneStepFlow.new
        workflow.start_workflow(params)
        batch = workflow.step_1_batch(RSpec::Sidekiq::NullStatus.new, params)

        expect(batch.description).to eq("OneStepFlow step_1 Batch")
      end

      it "the batch callback should fire on success" do
        id = 1

        params = { id: id }
        workflow = TwoStepFlow.new
        workflow.start_workflow(params)
        batch = workflow.step_1_batch(RSpec::Sidekiq::NullStatus.new, params)

        expect(batch.instance_variable_get("@callbacks").flatten.first).to eq(:success)
      end
    end

    it "triggers the second step after the first step" do
      first_id = 1
      second_id = 2
      parent_bid = 5
      job_stub = create_job_stub
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = { first_id: first_id, second_id: second_id }
      workflow = TwoStepFlow.new
      workflow.start_workflow(params)

      expect(job_stub).to have_received(:perform_async).with(second_id)
    end

    it "triggers as many steps as there are defined step methods" do
      parent_bid = 5
      job_stub = create_job_stub
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = { id: 1, second_id: 2, third_id: 3, fourth_id: 4 }
      workflow = FourStepFlow.new
      workflow.start_workflow(params)

      expect(job_stub).to have_received(:perform_async).with(params[:id])
      expect(job_stub).to have_received(:perform_async).with(params[:second_id])
      expect(job_stub).to have_received(:perform_async).with(params[:third_id])
      expect(job_stub).to have_received(:perform_async).with(params[:fourth_id])
    end

    it "only triggers steps that exist" do
      first_id = 1
      second_id = 1
      parent_bid = 5
      job_stub = create_job_stub
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = { first_id: first_id, second_id: second_id }
      workflow = TwoStepFlow.new
      workflow.start_workflow(params)

      expect(job_stub).not_to have_received(:perform_async).with(params[:third_id])
    end

    it "only has callbacks for steps that exist" do
      id = 1
      parent_bid = 5
      job_stub = create_job_stub
      allow(RSpec::Sidekiq::NullStatus).
        to receive(:parent_bid).
        and_return(parent_bid)

      params = {
        first_id: id,
        second_id: 2,
        third_id: 3,
        fourth_id: 4,
        fifth_id: 5,
        sixth_id: 6,
        seventh_id: 7,
        eigth_id: 8,
        ninth_id: 9,
        tenth_id: 10,
      }
      workflow = TwoStepFlow.new
      workflow.start_workflow(params)

      expect(job_stub).to have_received(:perform_async).with(params[:first_id])
      expect(job_stub).to have_received(:perform_async).with(params[:second_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:third_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:fourth_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:fifth_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:sixth_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:seventh_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:eight_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:ninth_id])
      expect(job_stub).not_to have_received(:perform_async).with(params[:tenth_id])
    end

    context "when a step has no workers defined" do
      it "enqueues the NoopWorker" do
        first_id = 1
        second_id = 2
        parent_bid = 3
        job_stub = create_job_stub
        options = { first_id: first_id, second_id: second_id }
        allow(RSpec::Sidekiq::NullStatus).
          to receive(:parent_bid).
          and_return(parent_bid)

        workflow = EmptyFlow.new
        workflow.start_workflow(options)

        expect(job_stub).to have_received(:perform_async).with(second_id)
      end
    end
  end

  def create_job_stub
    class_stub = class_double(ExampleJob).as_stubbed_const
    allow(class_stub).to receive(:perform_async)
    class_stub
  end
end
