# used to process batches marked as outside finly
# 
class Settlement::SMoneyRequests::Processing::GenerateTemplateFile < Settlement::SMoneyRequests::Processing::Base

  attr_accessor :company, :sample_type, :headers, :content, :sheets, :money_request_processor

  def init
    groups_presenter = Settlement::SMoneyRequests::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:money_request_processor_id] or params[:id])
    self.money_request_processor = groups_presenter.money_request_processors.find_by id: id

    self.content = params[:content] || []
  end

  def validate
    if self.money_request_processor.blank?
      add_message :error, "Details for advance processing not found."
      return
    end

    unless self.money_request_processor.process_outside_finly?
      add_message :error, "You can upload UTR details only for payments processed through payment file or outside Finly."
      return
    end
  end

  def process
    self.sheets = []

    # adding Item to excel sheet
    item_headers = default_headers
    item_contents = (self.content.blank?) ? [] : self.content

    if self.content.blank?
      # self.money_request_processor.mappings.exclude_cancelled.each do |item|
      self.money_request_processor.mappings.exclude_cancelled.left_joins(:money_requests).select('money_request_processor_mappings.*, money_requests.id AS money_request_id, money_requests.bank_reference_number AS mr_bank_reference_number, money_requests.source_account AS mr_source_account').each do |item|
        item_contents << processor_details(self.money_request_processor, item)
      end
    end

    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: "Process Advances Outside Finly"
    }

  end

  def success
    Exporter.new(user, {xlsx: {headers: self.headers, contents: self.content, sheets: self.sheets}, expire_file_duration: 1.day}, messages)
  end

  private

  def processor_details(processor, item)
    marked_as_completed = (item.completed?) ? 'Y' : ''
    msg = (item.completed?) ? '(only UTR updateable)' : ''
    # document_ids = item.money_requests.pluck(:id).join(", ") rescue ""
    [
      # document_ids,
      item.money_request_id,
      item.id,
      processor.created_by_user&.name,
      item.processor_accountable&.name,
      item.processor_accountable&.account_number,
      item.user&.name,
      item.note,
      item.money_requests.find_by(id: item.money_request_id).total_amount,
      item.mr_bank_reference_number,
      item.mr_source_account,
      marked_as_completed,
      msg
    ]
  end

  def default_headers
    [
      "Advance ID(unmodifiable)",
      "Batch Item ID(unmodifiable)",
      "Batch Created By(unmodifiable)", 
      "Beneficiary Account Name(unmodifiable)",
      "Beneficiary Account Number(unmodifiable)",
      "Advance Requested By User(unmodifiable)", 
      "Purpose of Advance(unmodifiable)", 
      "Total Advance Amount(unmodifiable)", 
      "UTR",
      "Source Account",
      "Mark As Paid(Y or N)"
    ]
  end

end
