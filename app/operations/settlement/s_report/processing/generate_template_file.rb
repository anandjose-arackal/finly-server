# used to process batches marked as outside finly
# 
class Settlement::SReport::Processing::GenerateTemplateFile < Settlement::SReport::Processing::Base

  attr_accessor :company, :sample_type, :headers, :content, :sheets, :report_processor_group

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:report_processor_group_id] or params[:id])
    self.report_processor_group = groups_presenter.report_processor_groups.find_by id: id

    self.content = params[:content] || []
  end

  def validate
    if self.report_processor_group.blank?
      add_message :error, "Details for processing report not found."
      return
    end

    unless self.report_processor_group.process_outside_finly?
      add_message :error, "You can upload UTR details only for report group processed through payment file or outside Finly."
      return
    end
  end

  def process
    self.sheets = []

    # adding Item to excel sheet
    item_headers = default_headers
    item_contents = (self.content.blank?) ? [] : self.content

    if self.content.blank?
      self.report_processor_group.mappings.exclude_cancelled.each do |item|
        item_contents << processor_details(self.report_processor_group, item)
      end
    end

    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: "Process Reports Outside Finly"
    }

  end

  def success
    Exporter.new(user, {xlsx: {headers: self.headers, contents: self.content, sheets: self.sheets}, expire_file_duration: 1.day}, messages)
  end

  private

  def processor_details(processor, item)
    marked_as_completed = (item.completed?) ? 'Y(only UTR updatable)' : ''
    document_ids = item.reports.pluck(:id).join(", ") rescue ""
    [
      item.id,
      document_ids,
      processor.created_by_user&.name,
      item.processor_accountable&.name,
      item.processor_accountable&.account_number,
      item.user&.name,
      item.note,
      item.amount&.value,
      item.bank_reference_number,
      marked_as_completed
    ]
  end

  def default_headers
    [
      "Batch Item ID(unmodifiable)",
      "Report IDs(unmodifiable)",
      "Batch Created By(unmodifiable)", 
      "Beneficiary Account Name(unmodifiable)",
      "Beneficiary Account Number(unmodifiable)",
      "Report Requested By User(unmodifiable)", 
      "Purpose of Report(unmodifiable)", 
      "Total Report Amount(unmodifiable)", 
      "UTR",
      "Mark As Paid(Y or N)"
    ]
  end

end
