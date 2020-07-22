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
    unless user.has_role?(UserRole.id_for(:finance_manager)) or user.has_role?(UserRole.id_for(:admin))
      add_message :error, 'You are not authorized to perform this action'
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
      data = Exporter.new(user, {xml: {template: template, local_variables: {expenses: expenses, configuration: current_company.tally_configuration}}}, messages).xml_exporter.generate_xml
      save_file(data)
    end
  end

  def post_process
    self.reports.update_all(sync_status_id: ReportSyncStatus.id_for(:exported), sync_type_id: ReportSyncType.id_for(:tally_export))
  end

  def success
    Integrations::Tally::Vouchers::SuccessPresenter.new(user, {file_url: self.file_url}, messages)
  end


  def save_file(data)
    url =""
    azure_config = Rails.application.config_for(:azure_config)&.with_indifferent_access
    blob_client = Azure::Storage::Blob::BlobService.create(
        storage_account_name: azure_config["storage_account_name"],
        storage_access_key: azure_config["storage_access_key"],
    )
    container_name = azure_config["container"]
    options = { content_type: 'application/xml', content_disposition: 'attachment;' }

    unique_file_name = create_uniq_file_name
    file = File.open("/tmp/#{unique_file_name}",'w+')
    file.write data
    if file
      file_name = File.basename(file)
      blob_client.create_block_blob(container_name, file_name, file, options)
      url = "https://#{azure_config["storage_account_name"]}.blob.core.windows.net/#{container_name}/#{file_name}"
    end
    url
  end

  def create_uniq_file_name
    "export#{Time.now.utc.strftime("%Y%m%d%H%M%S")}#{SecureRandom.hex(10)}"
  end

end


