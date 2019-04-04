class Integrations::Tally::Vouchers < Integrations::Tally::Base
  attr_accessor :expenses, :reports, :file_url

  class Integrations::Tally::Vouchers::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end

  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless current_company.tally_configuration.present? and current_company.tally_configuration.active
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end
    if params[:id].blank? and not params[:filtered]
      add_message :error, 'Report not found'
      return
    end
  end

  def process
    reports_presenter = Reports::Index.(user, params)
    unless reports_presenter&.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    self.reports = reports_presenter.reports
    if params[:filtered]
      self.reports = self.reports.processed
    else
      id = params[:id] || params[:report_id]
      id = id.split(',')
      self.reports = self.reports.with_id(id)
    end
    report_ids = reports.pluck(:id)
    self.expenses = Expense.with_report_id(report_ids)
    if user.company.tally_configuration.excel_export
      params[:type] = :tally_expense_voucher_xls
      result = ExportManager::RequestHandler.(user, params)
      unless result.success?
        add_message :error, result.messages[:error]
        return
      end
      self.file_url = result.file_url
    else
      if user.company.tally_configuration.custom_voucher
        template = "#{Rails.root}/lib/personalizer/adapters/company#{user.company_id}/tally/vouchers.xml"
      else
        current_class_path = self.method(:success).source_location.first.gsub('/vouchers.rb', '')
        template = "#{current_class_path}/vouchers.xml"
      end
      self.file_url = Exporter.new(user, {xml: {template: template, local_variables: {expenses: expenses, configuration: current_company.tally_configuration}}}, messages).generate_xml
    end
  end

  def post_process
    self.reports.update_all(sync_status_id: ReportSyncStatus.id_for(:exported), sync_type_id: ReportSyncType.id_for(:tally_export))
  end

  def success
    Integrations::Tally::Vouchers::SuccessPresenter.new(user, {file_url: self.file_url}, messages)
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end


