class Dashboard::ExpenseManagement::Reports < Dashboard::ExpenseManagement::Base
  attr_accessor :reports

  def init
    # {"view"=>"personal", "menu"=>{"main"=>"reports"}, "page"=>"1", "per_page"=>"30"}
    self.reports = Reports::Index.(user, params)

  end

  def success
    params[:reports] = self.reports
    Dashboard::ExpenseManagement::Reports::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::ExpenseManagement::Reports::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports, :counts

    def init
      general_filter_params = {
      }

      self.reports = params[:reports].reports.includes(expenses: [:amount])

      self.counts = []

      personal_report_data = {
        type: 'personal_report',
        data: [
          {
            title: "Not Submitted Reports",
            count: self.reports.filter_status(1, user.id).count,
            total_amount: self.reports.filter_status(1, user.id).map {|report| report.total_amount}&.compact&.sum,
            filters: []
          },

          {
            title: "Processing Reports",
            count: self.reports.filter_status(2, user.id).count,
            total_amount: self.reports.filter_status(2, user.id).map {|report| report.total_amount}&.compact&.sum,
            filters: []
          },

          {
            title: "Rejected Reports",
            count: self.reports.filter_status(4, user.id).count,
            total_amount: self.reports.filter_status(4, user.id).map {|report| report.total_amount}&.compact&.sum,
            filters: []
          },

          {
            title: "Approved Reports",
            count: self.reports.filter_status(5, user.id).count,
            total_amount: self.reports.filter_status(5, user.id).map {|report| report.total_amount}&.compact&.sum,
            filters: []
          }
        ]

      }

      self.counts << personal_report_data

    end
  end
end
