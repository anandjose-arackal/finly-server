class TdsSlabs::Base < BaseOperation

  def pre_validate
    if user.blank? && params.blank?
      add_message :error, "Invalid request, try again"
      return
    end
  end

  def tds_slab_params
    params.require(:tds_slab).permit(:name, :tds)
  end
end