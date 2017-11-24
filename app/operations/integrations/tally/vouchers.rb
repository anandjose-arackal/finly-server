class Integrations::Tally::Vouchers < Integrations::Tally::Base
  attr_accessor :expenses, :reports

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless current_company.tally_configuration.present? and current_company.tally_configuration.active
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end
    unless params[:id].present? and not params[:all]
      add_message :error, 'Report not found'
      return
    end
  end

  def process
    reports_presenter = Report::Index.(user, params)
    unless reports_presenter&.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    self.reports = reports_presenter.reports
    unless params[:filtered]
      id = params[:id] || params[:report_id]
      id = id.split(',')
      self.reports = self.reports.with_id(id)
    end
    report_ids = reports.pluck(:id)
    self.expenses = Expense.with_report_id(report_ids)
    current_class_path = self.method(:success).source_location.first.gsub('/vouchers.rb', '')
    template = "#{current_class_path}/tally.xml"
    self.response = Exporter.new(user, {xml: {template: template, local_variables: {expenses: expenses, company_name: current_company.tally_configuration.company_name}}}, messages)
  end

  def post_process
    self.reports.update_all(sync_status_id: ReportSyncStatus.id_for(:exported), sync_type_id: ReportSyncType.id_for(:tally_export))
  end

  def success
    self.response
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end