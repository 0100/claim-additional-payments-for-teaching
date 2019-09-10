require "rails_helper"

describe Admin::ClaimsHelper do
  let(:claim_school) { schools(:penistone_grammar_school) }
  let(:current_school) { create(:school, :student_loan_eligible) }

  describe "eligibility_answers" do
    let(:eligibility) do
      build(
        :student_loans_eligibility,
        qts_award_year: "2013_2014",
        claim_school: claim_school,
        current_school: current_school,
        chemistry_taught: true,
        physics_taught: true,
        had_leadership_position: true,
        mostly_performed_leadership_duties: false,
        student_loan_repayment_amount: 1987.65,
      )
    end

    it "returns an array of questions and answers for displaying to approver" do
      expected_answers = [
        [I18n.t("student_loans.questions.admin.qts_award_year"), "1 September 2013 to 31 August 2014"],
        [I18n.t("student_loans.questions.admin.claim_school"), claim_school.name],
        [I18n.t("questions.admin.current_school"), current_school.name],
        [I18n.t("student_loans.questions.admin.subjects_taught"), "Chemistry and Physics"],
        [I18n.t("student_loans.questions.admin.had_leadership_position"), "Yes"],
        [I18n.t("student_loans.questions.admin.mostly_performed_leadership_duties"), "No"],
      ]

      expect(helper.admin_eligibility_answers(eligibility)).to eq expected_answers
    end

    it "excludes questions skipped from the flow" do
      eligibility.had_leadership_position = false
      expect(helper.admin_eligibility_answers(eligibility)).to include([I18n.t("student_loans.questions.admin.had_leadership_position"), "No"])
      expect(helper.admin_eligibility_answers(eligibility)).to_not include([I18n.t("student_loans.questions.admin.mostly_performed_leadership_duties"), "No"])
    end
  end

  describe "admin_personal_details" do
    let(:claim) do
      build(
        :claim,
        first_name: "Bruce",
        surname: "Wayne",
        teacher_reference_number: "1234567",
        national_insurance_number: "QQ123456C",
        email_address: "test@email.com",
        address_line_1: "Flat 1",
        address_line_2: "1 Test Road",
        address_line_3: "Test Town",
        postcode: "AB1 2CD",
        date_of_birth: Date.new(1901, 1, 1),
      )
    end

    it "includes an array of questions and answers" do
      expected_answers = [
        [I18n.t("questions.admin.teacher_reference_number"), "1234567"],
        [I18n.t("verified_fields.full_name").capitalize, "Bruce Wayne"],
        [I18n.t("questions.admin.national_insurance_number"), "QQ123456C"],
        [I18n.t("verified_fields.date_of_birth").capitalize, "1 January 1901"],
        [I18n.t("verified_fields.address").capitalize, "Flat 1<br>1 Test Road<br>Test Town<br>AB1 2CD"],
        [I18n.t("questions.admin.email_address"), "test@email.com"],
      ]

      expect(helper.admin_personal_details(claim)).to eq expected_answers
    end
  end
end
