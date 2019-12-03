class Payment < ApplicationRecord
  has_one :claim
  belongs_to :payroll_run

  validates :award_amount, presence: true

  validates :payroll_reference, :gross_value, :national_insurance, :employers_national_insurance, :tax, :net_pay, :gross_pay, presence: true, on: :upload
  validates :gross_value, :national_insurance, :employers_national_insurance, :student_loan_repayment, :tax, :net_pay, :gross_pay, numericality: true, allow_nil: true
end
