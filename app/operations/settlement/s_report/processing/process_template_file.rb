class Settlement::SReport::Processing::ProcessTemplateFile < Settlement::SReport::Processing::Base

  attr_accessor :file, 
                :parsed_data, 
                :item_details, 
                :headers, 
                :contents, 
                :validate_operation,
                :report_processor_group, 
                :pending_items, 
                :pending_item_ids,
                :completed_items,
                :edge_case 
                :just_show_excel,
                :associated_utr

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end

    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:report_processor_group_id] or params[:id])
    self.report_processor_group = groups_presenter.report_processor_groups.find_by id: id

    if self.report_processor_group.blank?
      add_message :error, "Details for processing report not found."
      return
    end

  end

  def init

    self.file = params[:file]
    headers = [:report_id, :batch_created_by, :beneficiary_account_name, :beneficiary_account_number, :report_requested_by_user, :purpose_of_report, :total_report_amount, :utr, :mark_as_paid]
    begin
      self.parsed_data = ImportUtil.load_spreadsheet(file, headers, {skip_empty_lines: true})
    rescue Ole::Storage::FormatError => e
      add_message :error, "File Format error. Please re-save your Excel sheet in 2007 format or greater."
    end

    # deal with an edge case where neither utr nor mark_as_paid column is filled up
    empty_rows = self.parsed_data.collect {|data| data if (data[:utr].blank? && (!!StringUtils.to_bool(data[:mark_as_paid]&.downcase) == false))}.compact
    self.edge_case = (empty_rows.count == self.parsed_data.count)

    # a flag, used to handle failure logic, whether to show excel file or just the errors
    self.just_show_excel = true
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end

    unless MoneyRequestProcessorStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.report_processor_group.status_id)
      add_message :error, 'Items in this batch cannot be processed at this stage'
      return
    end

    if self.edge_case
      add_message :error, "None of the reports were marked as paid."
      return
    end
  end

  def pre_process
    self.validate_operation = Settlement::SReport::Processing::BulkValidateFileData.(user, {item_details: self.parsed_data})
    if validate_operation.success?

    else
      self.contents = validate_operation.contents
      self.headers = validate_operation.headers
      add_message :error, "Some of the reports have errors, please check the downloaded file to resolve them"
      return
    end

    self.pending_items = self.report_processor_group.mappings.not_completed.where id: self.validate_operation.item_details.pluck(:advance_id)
    self.pending_item_ids = self.pending_items.pluck(:id) rescue []

    # user is allowed to update utr for completed items
    self.completed_items = self.report_processor_group.mappings.completed.where id: self.validate_operation.item_details.pluck(:advance_id)
  end

  def process
    # 
    # we will use this to cleanly map report ids and utr
    self.associated_utr = {}
    self.validate_operation.item_details.pluck(:report_id,:utr).map { |id, utr| self.associated_utr[id.to_i] = utr }

    # utr can be updated for items which are already completed
    self.completed_items.each do |item|
      if item.bank_reference_number != self.associated_utr[item.id]&.strip
        item.update(bank_reference_number: self.associated_utr[item.id])
      end
    end

    # only if anything is pending, we call the post_opertion to update the item and in turn the batch
    if self.pending_item_ids.present?
      result = Settlement::SReport::Processing::PostOperation.(self.report_processor_group, {marked_as_completed: true, request_ids: self.pending_item_ids, utr: self.associated_utr}, true)
    end

    unless result.success?
      self.just_show_excel = false
      add_message :error, result.messages[:error]
      return
    end
  end

  def post_process
    add_message :success, "Succesfully processed file."
  end

  def success
    params[:just_show_excel] = self.just_show_excel
    Settlement::SReport::Processing::ProcessTemplateFile::SuccessPresenter.new(user, params, messages)    
  end

  # this method should create the temporary file that can be linked in the front end
  def failure
    if self.just_show_excel
      params[:content] = self.contents
      result = Settlement::SReport::Processing::GenerateTemplateFile.(user, params)

      if result.success?
        params[:just_show_excel] = self.just_show_excel
        params[:result_file_path] = result.xlsx_exporter.export_file_path
        Settlement::SReport::Processing::ProcessTemplateFile::FailurePresenter.new(user, params, messages)
      else
        add_message :error, "Some Internal Error Occurred"
      end
    else
      params[:just_show_excel] = self.just_show_excel
      Settlement::SReport::Processing::ProcessTemplateFile::FailurePresenter.new(user, params, messages)
    end
  end

  class Settlement::SReport::Processing::ProcessTemplateFile::SuccessPresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :just_show_excel

    def init
      self.just_show_excel = params[:just_show_excel]
    end
  end

  class Settlement::SReport::Processing::ProcessTemplateFile::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path, :just_show_excel

    def init
      self.result_file_path = params[:result_file_path]
      self.just_show_excel = params[:just_show_excel]
    end
  end

end
