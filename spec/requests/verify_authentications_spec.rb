require "rails_helper"
require "verify/fake_sso"

RSpec.describe "GOV.UK Verify::AuthenticationsController requests", type: :request do
  context "when a claim is in progress" do
    before { post claims_path }

    describe "verify/authentications/new" do
      before do
        stub_vsp_generate_request
        get new_verify_authentications_path
      end

      it "renders a form that will submit an authentication request to Verify" do
        expect(response.body).to include("action=\"#{stubbed_auth_request_response["ssoLocation"]}\"")
        expect(response.body).to include(stubbed_auth_request_response["samlRequest"])
      end

      it "stores the request_id in the user’s session" do
        expect(session[:verify_request_id]).to eql(stubbed_auth_request_response["requestId"])
      end
    end

    describe "POST verify/authentications (i.e. the verify callback handler)" do
      before do
        post claims_path

        stub_vsp_generate_request
        get new_verify_authentications_path # sets the authentication request request_id in the session
      end

      let(:current_claim) { TslrClaim.order(:created_at).last }

      context "given an IDENTITY_VERIFIED SAML response" do
        let(:saml_response) { Verify::FakeSso::IDENTITY_VERIFIED_SAML_RESPONSE }

        before do
          stub_vsp_translate_response_request
          post verify_authentications_path, params: {"SAMLResponse" => saml_response}
        end

        it "saves the translated identity attributes on the current claim and redirects to the next question" do
          expect(response).to redirect_to(claim_path("teacher-reference-number"))

          expect(current_claim.full_name).to eq("Isambard Kingdom Brunel")
          expect(current_claim.address_line_1).to eq("Verified Street")
          expect(current_claim.address_line_2).to eq("Verified Town")
          expect(current_claim.address_line_3).to eq("Verified County")
          expect(current_claim.postcode).to eq("M12 345")
          expect(current_claim.date_of_birth).to eq(Date.new(1806, 4, 9))
        end
      end
    end
  end

  context "when a claim hasn’t been started yet" do
    before { stub_vsp_generate_request }

    it "redirects to the start page" do
      get new_verify_authentications_path
      expect(response).to redirect_to(root_path)

      post verify_authentications_path
      expect(response).to redirect_to(root_path)
    end
  end
end
