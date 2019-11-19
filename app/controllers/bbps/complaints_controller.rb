class Bbps::ComplaintsController < BaseControllers::WebBase
  def index
    @op = Docs::UtilityBills::Complaints::Ops::Index.(params, 'current_user' => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def create
    @op = Docs::UtilityBills::Complaints::Ops::Raise.(params, 'current_user' => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def show
    params[:complaint_id] = params[:id] || params[:complaint_id]
    @op = Docs::UtilityBills::Complaints::Ops::Status.(params, 'current_user' => current_user)
    respond_to do |format|
      format.json {}
    end
  end
end