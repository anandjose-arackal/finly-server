 class Reports::Show < Reports::Base

  def post_process
    super()
    if params[:ref] == '1' and params[:n_id].present?
      Event::EReport::Unset.(user, params)
    end
  end

end
