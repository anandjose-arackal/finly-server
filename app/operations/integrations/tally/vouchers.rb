class Integrations::Tally::Vouchers < Integrations::Tally::Base
  attr_accessor :expenses

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless current_company.tally_configuration.present? and current_company.tally_configuration.active
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end
  end

  def process
    reports_presenter = Report::Index.(user, params)
    unless reports_presenter&.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    reports = reports_presenter.reports
    report_ids = reports.pluck(:id)
    self.expenses = Expense.with_report_id(report_ids)
  end

  def success
    current_class_path = self.method(:success).source_location.first.gsub('/vouchers.rb', '')
    template = "#{current_class_path}/tally.xml"
    Exporter.new(user, {xml: {template: template, local_variables: {expenses: expenses, company_name: current_company.tally_configuration.company_name}}}, messages)
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end