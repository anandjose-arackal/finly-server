class ApprovalTatReportsController < BaseControllers::WebBase

  layout 'trailblazers'

  def export_reports
    endpoint ApprovalTatReports::Create
    respond_to do |format|
      format.json {}
    end
  end
  
end