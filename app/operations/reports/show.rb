 class Reports::Show < Reports::Base

   def init
     id = (params[:id] or params[:report_id])
     self.report = Report.where(company_id: user.company_id).with_id(id).first rescue nil
   end

  def post_process
    super()
    if params[:ref] == '1' and params[:n_id].present?
      Event::EReport::Unset.(user, params)
    end
  end

end
