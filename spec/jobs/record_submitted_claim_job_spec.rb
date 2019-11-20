require "rails_helper"
require "geckoboard"

RSpec.describe RecordSubmittedClaimJob do
  let(:claim) { build(:claim, :submitted) }

  subject { described_class.new }

  it "sends the claim's reference, policy and submitted date to claims.submitted.ENV dataset" do
    ClimateControl.modify ENVIRONMENT_NAME: "environment_name" do
      claim_data = {
        reference: claim.reference,
        policy: claim.policy.to_s,
        performed_at: claim.submitted_at.strftime("%Y-%m-%dT%H:%M:%S%:z"),
      }

      dataset_post_stub = stub_geckoboard_dataset_update("claims.submitted.environment_name")

      subject.perform(claim)

      expect(dataset_post_stub.with(body: {data: [claim_data]})).to have_been_requested
    end
  end
end