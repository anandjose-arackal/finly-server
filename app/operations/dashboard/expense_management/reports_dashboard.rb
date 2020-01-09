class Dashboard::ExpenseManagement::ReportsDashboard < Dashboard::ExpenseManagement::Base
  attr_accessor :reports

  def init
    # {"view"=>"personal", "menu"=>{"main"=>"reports"}, "page"=>"1", "per_page"=>"30"}
    params[:view] = get_relevant_view
    self.reports = ::Reports::Index.(user, params)

  end

  def success
    params[:reports] = self.reports
    Dashboard::ExpenseManagement::ReportsDashboard::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::ExpenseManagement::ReportsDashboard::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports, :counts

    # has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      general_filter_params = {
      }

      self.reports = apply_scopes(params[:reports], params)
      self.reports = self.reports.reports.includes(expenses: [:amount])

      self.counts = []

      personal_report_data = {
          type: 'personal_report',
          data: [
              {
                  title: "Unsubmitted",
                  count: self.reports.filter_status(1, user.id).count,
                  total_amount: self.reports.filter_status(1, user.id).map {|report| report.total_amount}&.compact&.sum,
                  filters: [{filter_status: 1}]
              },

              {
                  title: "Processing",
                  count: self.reports.filter_status(2, user.id).count,
                  total_amount: self.reports.filter_status(2, user.id).map {|report| report.total_amount}&.compact&.sum,
                  filters: [{filter_status: 2}]
              },

              {
                  title: "Rejected",
                  count: self.reports.filter_status(4, user.id).count,
                  total_amount: self.reports.filter_status(4, user.id).map {|report| report.total_amount}&.compact&.sum,
                  filters: [{filter_status: 4}]
              },

              {
                  title: "Approved",
                  count: self.reports.filter_status(5, user.id).count,
                  total_amount: self.reports.filter_status(5, user.id).map {|report| report.total_amount}&.compact&.sum,
                  filters: [{filter_status: 5}]
              }
          ]

      }

      self.counts << personal_report_data

    end
  end
end
