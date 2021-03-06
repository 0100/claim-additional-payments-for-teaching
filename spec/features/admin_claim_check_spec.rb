require "rails_helper"

RSpec.feature "Admin checks a claim" do
  context "User is logged in as a service operator" do
    before { @signed_in_user = sign_in_as_service_operator }

    scenario "User can approve a claim" do
      freeze_time do
        stub_geckoboard_dataset_update
        submitted_claims = create_list(:claim, 5, :submitted, policy: StudentLoans)
        claim_to_approve = submitted_claims.first

        click_on "View claims"

        expect(page).to have_content(claim_to_approve.reference)
        expect(page).to have_content("5 claims awaiting a decision")

        find("a[href='#{admin_claim_tasks_path(claim_to_approve)}']").click
        click_on "Approve or reject this claim"

        choose "Approve"
        fill_in "Decision notes", with: "Everything matches"
        perform_enqueued_jobs { click_on "Confirm decision" }

        expect(claim_to_approve.latest_decision.created_by).to eq(@signed_in_user)
        expect(claim_to_approve.latest_decision.notes).to eq("Everything matches")

        expect(page).to have_content("Claim has been approved successfully")
        expect(page).to_not have_content(claim_to_approve.reference)

        expect(ActionMailer::Base.deliveries.count).to eq(1)

        mail = ActionMailer::Base.deliveries.first

        expect(mail.subject).to match("been approved")
        expect(mail.to).to eq([claim_to_approve.email_address])
        expect(mail.body.raw_source).to match("been approved")
      end
    end

    scenario "they can reject a claim" do
      stub_geckoboard_dataset_update
      submitted_claims = create_list(:claim, 5, :submitted)
      claim_to_reject = submitted_claims.first

      click_on "View claims"

      expect(page).to have_content(claim_to_reject.reference)
      expect(page).to have_content("5 claims awaiting a decision")

      find("a[href='#{admin_claim_tasks_path(claim_to_reject)}']").click
      click_on "Approve or reject this claim"

      choose "Reject"
      fill_in "Decision notes", with: "TRN doesn't exist"
      perform_enqueued_jobs { click_on "Confirm decision" }

      expect(claim_to_reject.latest_decision.created_by).to eq(@signed_in_user)
      expect(claim_to_reject.latest_decision.notes).to eq("TRN doesn't exist")

      expect(page).to have_content("Claim has been rejected successfully")
      expect(page).to_not have_content(claim_to_reject.reference)

      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to match("been rejected")
      expect(mail.to).to eq([claim_to_reject.email_address])
      expect(mail.body.raw_source).to match("not been able to approve")
    end

    scenario "User can see completed tasks" do
      ten_minutes_ago = 10.minutes.ago
      checking_user = create(:dfe_signin_user, given_name: "Fred", family_name: "Smith")
      uploading_user = create(:dfe_signin_user, given_name: "Trevor", family_name: "Nelson")
      qualification_task = build(:task, name: "qualifications", created_by: uploading_user, created_at: ten_minutes_ago, manual: false)
      employment_task = build(:task, name: "employment", created_by: checking_user, created_at: ten_minutes_ago, passed: false, manual: true)
      claim_with_tasks = create(:claim, :submitted, tasks: [qualification_task, employment_task])
      visit admin_claim_tasks_path(claim_with_tasks)

      expect(page).to have_content("Check qualification information Passed")
      expect(page).to have_content("Check employment information Failed")
      expect(page).to have_link("Approve or reject this claim", href: new_admin_claim_decision_path(claim_with_tasks))

      click_on "Check qualification information"
      expect(page).to have_content("Passed")
      expect(page).to have_content("This task was performed by an automated check uploaded by #{uploading_user.full_name}")
      expect(page).to have_content(I18n.l(ten_minutes_ago))
      expect(page).not_to have_button("Save and continue")

      click_on "Back"
      click_on "Check employment information"
      expect(page).to have_content("Failed")
      expect(page).to have_content("This task was performed by #{checking_user.full_name}")
      expect(page).to have_content(I18n.l(ten_minutes_ago))
    end

    scenario "User can see existing decision details" do
      claim_with_decision = create(:claim, :submitted, decisions: [build(:decision, result: :approved, notes: "Everything matches")])
      visit admin_claim_path(claim_with_decision)

      expect(page).not_to have_button("Confirm decision")
      expect(page).to have_content("Claim decision")
      expect(page).to have_content("Approved")
      expect(page).to have_content(claim_with_decision.latest_decision.notes)
      expect(page).to have_content("Created by")
      expect(page).to have_content(@signed_in_user.full_name)
    end
  end

  context "User is logged in as a payroll operator or a support user" do
    [DfeSignIn::User::SUPPORT_AGENT_DFE_SIGN_IN_ROLE_CODE, DfeSignIn::User::PAYROLL_OPERATOR_DFE_SIGN_IN_ROLE_CODE].each do |role|
      scenario "User cannot view claims" do
        sign_in_to_admin_with_role(role)

        expect(page).to_not have_link(nil, href: admin_claims_path)

        visit admin_claims_path

        expect(page.status_code).to eq(401)
        expect(page).to have_content("Not authorised")
      end
    end
  end
end
