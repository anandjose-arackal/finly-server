class CostCenters::Base < BaseOperation

  attr_accessor :company

  def init
    self.company = user.company if params[:company_id].blank?
    self.company = Company.find_by_id params[:company_id] if params[:company_id].present?
  end

  def pre_validate
    if user.blank? && params.blank?
      add_message :error, "Invalid request, try again"
      return
    end
  end

  def cost_center_params
    params.require(:cost_center).permit(:name)
  end
end