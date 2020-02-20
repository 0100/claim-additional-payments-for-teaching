class Admin::ChecksController < Admin::BaseAdminController
  before_action :ensure_service_operator
  before_action :load_claim

  CHECKS_SEQUENCE = %w[qualifications employment]

  def index
  end

  def show
    @eligibility_checks = @claim.policy::AdminChecksPresenter.new(@claim.eligibility)
    render current_check
  end

  def create
    Check.create!(name: current_check, claim: @claim, created_by: admin_user)
    redirect_to next_check_path
  end

  private

  def load_claim
    @claim = Claim.find(params[:claim_id])
  end

  def current_check
    params[:check].parameterize.underscore
  end

  def next_check
    CHECKS_SEQUENCE[CHECKS_SEQUENCE.index(current_check) + 1]
  end

  def next_check_path
    if next_check.present?
      admin_claim_check_path(@claim, check: next_check)
    else
      admin_claim_path(@claim)
    end
  end
end
