FactoryBot.define do
  factory :payment do
    association(:claim, factory: [:claim, :approved])
    association(:payroll_run, factory: :payroll_run)

    award_amount { claim.award_amount }

    trait :with_figures do
      gross_value { 487.48 }
      national_insurance { 33.9 }
      employers_national_insurance { 38.98 }
      student_loan_repayment { 0 }
      tax { 89.6 }
      net_pay { 325 }
    end
  end
end
