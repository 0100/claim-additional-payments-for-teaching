class Admin::UndoDecisionsController < Admin::BaseAdminController
  before_action :load_claim
  before_action :ensure_service_operator
  before_action :ensure_claim_has_undoable_decision

  def new
    @amendment = @claim.amendments.build
  end

  def create
    @amendment = Amendment.amend_claim(@claim, claim_params, amendment_params)

    if @amendment.persisted?
      redirect_to admin_claim_url(@claim)
    else
      render "new"
    end
  end

  private

  def load_claim
    @claim = Claim.find(params[:claim_id])
  end

  def ensure_claim_has_undoable_decision
    unless @claim.decision_undoable?
      render "decision_not_undoable"
    end
  end

  def claim_params
    params.require(:amendment).require(:claim).permit(*Claim::AMENDABLE_ATTRIBUTES)
  end

  def amendment_params
    {
      notes: params[:amendment][:notes],
      created_by: admin_user
    }
  end
end
