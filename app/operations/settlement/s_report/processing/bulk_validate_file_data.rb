class Settlement::SReport::Processing::BulkValidateFileData < Settlement::SReport::Processing::Base

  attr_accessor :item_details, :error_messages, :valid, :contents, :headers,
                :issues, :issue_item, :company_items, :items_in_sheet, :list_of_items, :items_found, :items_not_found,
                :all_departments, :all_departments_ids, :category_ids, :category, :cost_centers, :tax_rates

  class Settlement::SReport::Processing::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :item_details, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.item_details = params[:item_details]
      self.issues = params[:issues]
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
    
  end

  def validate

  end

  def pre_process

  end

  def process
    self.item_details.each do |item|
      report_id = item[:report_id] || item["report_id"]
      utr = item[:utr] || item["utr"]

      self.error_messages = []
      self.issue_item = {}

      if report_id.blank?
        self.valid = false
        self.error_messages << "Advance ID should not be removed."
        self.issue_item[:report_id] = "Advance ID should not be removed."
      end

      if utr.present?
        unless validate_utr utr
          self.valid = false
          self.error_messages << "UTR is only allowed to be alphanumeric."
          self.issue_item[:utr] = "UTR is only allowed to be alphanumeric."
        end
      end

      if valid

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
      "Advance ID(unmodifiable)", 
      "Batch Created By(unmodifiable)", 
      "Beneficiary Account Name(unmodifiable)",
      "Beneficiary Account Number(unmodifiable)",
      "Advance Requested By User(unmodifiable)", 
      "Purpose of Advance(unmodifiable)", 
      "Total Advance Amount(unmodifiable)", 
      "UTR",
      "Mark As Paid(Y or N; leave blank to skip)"
    ]
  end

end