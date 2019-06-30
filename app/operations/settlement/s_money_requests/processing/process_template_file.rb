class Settlement::SMoneyRequests::Processing::ProcessTemplateFile < Settlement::SMoneyRequests::Processing::Base

  attr_accessor :file, 
                :parsed_data, 
                :item_details, 
                :headers, 
                :contents, 
                :validate_operation,
                :money_request_processor, 
                :pending_items, 
                :pending_item_ids,
                :completed_items,
                :edge_case, 
                :processable_mappings,
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

    groups_presenter = Settlement::SMoneyRequests::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:money_request_processor_id] or params[:id])
    self.money_request_processor = groups_presenter.money_request_processors.find_by id: id

    if self.money_request_processor.blank?
      add_message :error, "Details for advance processing not found."
      return
    end

  end

  def init

    self.file = params[:file]
    headers = [:item_id, :batch_created_by, :beneficiary_account_name, :beneficiary_account_number, :advance_requested_by_user, :purpose_of_advance, :total_advance_amount, :utr, :mark_as_paid]
    begin
      self.parsed_data = ImportUtil.load_spreadsheet(file, headers, {skip_empty_lines: true})
    rescue Ole::Storage::FormatError => e
      add_message :error, "File Format error. Please re-save your Excel sheet in 2007 format or greater."
    end

    # a flag, used to handle failure logic, whether to show excel file or just the errors
    self.just_show_excel = false
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end

    unless MoneyRequestProcessorStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.money_request_processor.status_id)
      add_message :error, 'Items in this batch cannot be processed at this stage'
      return
    end
  end

  def pre_process
    self.validate_operation = Settlement::SMoneyRequests::Processing::BulkValidateFileData.(user, {item_details: self.parsed_data, batch: self.report_processor_group})
    if validate_operation.success?
      self.processable_mappings = self.validate_operation.processable_mappings
      if self.processable_mappings.blank?
        add_message :error, "No processable reports found"
        return
      end
    else
      self.just_show_excel = true
      self.contents = validate_operation.contents
      self.headers = validate_operation.headers
      add_message :error, "Some of the advances have errors, please check the downloaded file to resolve them"
      return
    end

    self.pending_items = self.money_request_processor.mappings.not_completed.where id: self.processable_mappings.pluck(:item_id)
    self.pending_item_ids = self.pending_items.pluck(:id) rescue []

    # user is allowed to update utr for completed items
    self.completed_items = self.money_request_processor.mappings.completed.where id: self.processable_mappings.pluck(:item_id)

  end

  def process
    # 
    # we will use this to cleanly map advance ids and utr
    self.associated_utr = {}
    self.processable_mappings.pluck(:item_id,:utr).map { |id, utr| self.associated_utr[id.to_i] = utr }

    # utr can be updated for items which are already completed
    self.completed_items.each do |item|
      if item.bank_reference_number != self.associated_utr[item.id]&.strip
        item.update(bank_reference_number: self.associated_utr[item.id])
      end
    end

    # only if anything is pending, we call the post_opertion to update the item and in turn the batch
    if self.pending_item_ids.present?
      result = Settlement::SMoneyRequests::Processing::PostOperation.(self.money_request_processor, {marked_as_completed: true, request_ids: self.pending_item_ids, utr: self.associated_utr}, true)
      unless result.success?
        self.just_show_excel = false
        add_message :error, result.messages[:error]
        return
      end
    end

    if self.money_request_processor.completed?
      params[:redirect] = true
    else
      params[:redirect] = false
    end
  end

  def post_process
    add_message :success, "Succesfully processed file."
  end

  def success
    params[:just_show_excel] = false
    Settlement::SMoneyRequests::Processing::ProcessTemplateFile::SuccessPresenter.new(user, params, messages)    
  end

  # this method should create the temporary file that can be linked in the front end
  def failure
    if self.just_show_excel
      params[:content] = self.contents
      result = Settlement::SMoneyRequests::Processing::GenerateTemplateFile.(user, params)

      if result.success?
        params[:just_show_excel] = self.just_show_excel
        params[:result_file_path] = result.xlsx_exporter.export_file_path
        Settlement::SMoneyRequests::Processing::ProcessTemplateFile::FailurePresenter.new(user, params, messages)
      else
        add_message :error, "Some Internal Error Occurred"
      end
    else
      params[:just_show_excel] = self.just_show_excel
      Settlement::SMoneyRequests::Processing::ProcessTemplateFile::FailurePresenter.new(user, params, messages)
    end
  end

  class Settlement::SMoneyRequests::Processing::ProcessTemplateFile::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path, :just_show_excel, :redirect

    def init
      self.result_file_path = params[:result_file_path]
      self.just_show_excel = params[:just_show_excel]
      # Helps to know in frontend if they should redirect to settlement index or simply re-render the same settlement show page
      self.redirect = params[:redirect]
    end
  end

  class Settlement::SMoneyRequests::Processing::ProcessTemplateFile::SuccessPresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :just_show_excel, :redirect

    def init
      self.just_show_excel = params[:just_show_excel]
      # Helps to know in frontend if they should redirect to settlement index or simply re-render the same settlement show page
      self.redirect = params[:redirect]
    end
  end

end
