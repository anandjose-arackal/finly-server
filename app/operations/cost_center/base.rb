class CostCenter::Base < BaseOperation

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