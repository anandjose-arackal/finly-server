class Settlement::SReport::Processing::BulkValidateFileData < Settlement::SReport::Processing::Base

  attr_accessor :item_details, :error_messages, :valid, :contents, :headers,
                :issues, :issue_item, :company_items, :items_in_sheet, :list_of_items, :items_found, :items_not_found,
                :all_departments, :all_departments_ids, :category_ids, :category, :cost_centers, :tax_rates,
                :batch, :item_utr, :item_status, :processable_mappings, :mappings, :item_source_account

  class Settlement::SReport::Processing::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :item_details, :issues, :processable_mappings

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.item_details = params[:item_details]
      self.issues = params[:issues]
      self.processable_mappings = params[:processable_mappings]
    end

  end

  class Settlement::SReport::Processing::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :contents, :headers, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.issues = params[:issues]
    end
  end

  def init
    self.item_details = params[:item_details]
    self.contents = []
    self.headers = retrieve_header_names
    # setting the valid as true here, so that even if one line item failed in the
    # below validations it will return false
    self.valid = true

    self.issues = []

    self.batch = params[:batch]
    self.mappings = self.batch.mappings.exclude_cancelled

    self.processable_mappings = []
  end

  def validate

  end

  def pre_process
    # self.item_utr = self.mappings.collect {|item| [item.id, item.bank_reference_number]}.to_h
    # self.item_utr = self.mappings.left_joins(:reports).select('reports.id AS report_id, reports.bank_reference_number AS utr').collect {|item| [item.report_id, item.utr]}.to_h

    documents = self.mappings.left_joins(:reports).select('reports.id AS report_id, reports.bank_reference_number AS utr, reports.source_account AS source_account')
    self.item_utr = documents.collect {|item| [item.report_id, item.utr]}.to_h
    self.item_source_account = documents.collect {|item| [item.report_id, item.source_account]}.to_h
    self.item_status = self.mappings.collect {|item| [item.id, item.status_id]}.to_h
  end

  def process
    self.item_details.each do |item|
      document_id = item[:document_id] || item["document_id"]
      item_id = item[:item_id] || item["item_id"]
      utr = item[:utr] || item["utr"]
      source_account = item[:source_account] || item["source_account"]

      self.error_messages = []
      self.issue_item = {}

      if item_id.blank?
        self.valid = false
        self.error_messages << "Batch ID should not be removed."
        self.issue_item[:item_id] = "Batch ID should not be removed."
      end

      if document_id.blank?
        self.valid = false
        self.error_messages << "Advance ID should not be removed."
        self.issue_item[:document_id] = "Advance ID should not be removed."
      end

      if utr.present?
        unless validate_utr utr
          self.valid = false
          self.error_messages << "UTR is only allowed to be alphanumeric."
          self.issue_item[:utr] = "UTR is only allowed to be alphanumeric."
        end
      end

      if source_account.present?
        unless validate_utr source_account
          self.valid = false
          self.error_messages << "Source Account is only allowed to be alphanumeric."
          self.issue_item[:source_account] = "Source Account is only allowed to be alphanumeric."
        end
      end

      if valid

        # if any of these checks are true, only then we consider the mapping to be processeable
        check1 = utr_present_or_marked_as_paid(item)
        check2 = utr_modifiable(item)

        if check1 && check2
          self.processable_mappings << item
        end

      end

      item[:errors] = self.error_messages.to_sentence if self.error_messages.present?

      self.contents << item.values

      self.issues << self.issue_item
    end
  end

  def success?
    self.valid
  end

  def failure?
    self.valid
  end

  def success
    params[:item_details] = self.item_details
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    params[:processable_mappings] = self.processable_mappings
    Settlement::SReport::Processing::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    Settlement::SReport::Processing::BulkValidateFileData::FailurePresenter.new(user, params, messages)
  end


  private

  def validate_utr(utr)
    ( /\A[a-zA-Z0-9]*\Z/.match(utr) ) ? true : false
  end

  def retrieve_header_names
    [
      "Report ID(unmodifiable)",
      "Batch Item ID(unmodifiable)",
      "Batch Created By(unmodifiable)",
      "Beneficiary Account Name(unmodifiable)",
      "Beneficiary Account Number(unmodifiable)",
      "Report Requested By User(unmodifiable)",
      "Purpose of Report(unmodifiable)",
      "Total Report Amount(unmodifiable)",
      "Total Reimbursable Amount(unmodifiable)", 
      "UTR",
      "Source Account",
      "Mark As Paid(Y or N; leave blank to skip)"
    ]
  end

  # any methods added here should be able to return true

  def utr_present_or_marked_as_paid(item)
    utr_present(item) || marked_as_paid(item)
  end

  def utr_present(item)
    item[:utr].present? or item[:source_account].present?
  end

  def marked_as_paid(item)
    !!StringUtils.to_bool(item[:mark_as_paid]&.downcase)
  end

  # we need this flag, since not all items will be credited through bank transfer
  def utr_modifiable(item)
    return true if item_utr[item[:document_id].to_i].blank? #mapping does not have a utr already present
    return true if item[:utr] != item_utr[item[:document_id].to_i] #mappings utr is different from excel enterted utr

    return true if item_source_account[item[:document_id].to_i].blank? #mapping does not have a source_account already present
    return true if item[:source_account] != item_source_account[item[:document_id].to_i] #mappings source_account is different from excel enterted source_account
  end

  # def can_be_marked_completed(item)
  #   item_status[item[:item_id].to_i] != ReportProcessorGroupStatus.id_for(:completed)
  # end


end