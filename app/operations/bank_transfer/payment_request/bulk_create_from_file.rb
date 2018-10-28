class BankTransfer::PaymentRequest::BulkCreateFromFile < BankTransfer::PaymentRequest::Base

  attr_accessor :file, :parsed_data, :response_presenter, :errors_found,
                :result_data

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    self.file = params[:file]
    headers = [:name, :bank_account_number, :ifsc, :original_amount,
               :inclusive_of_taxes, :gst_type_id, :tax, :discount, :tds_slab_id, :category_id, :cost_center_id, :invoice_number, :invoice_date, :due_date, :note]
    payment_order_custom_fields = current_company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    payment_order_custom_fields.each do |field|
      headers << field.field_name.gsub(" ", "_").underscore
    end
    self.parsed_data = ImportUtil.load_spreadsheet(file, headers,
                                                   {skip_empty_lines: true})
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end

    op = BankTransfer::PaymentRequest::BulkValidateFileData.(user, {order_details: self.parsed_data})
    if op.failure?
      self.result_data = op.result_data
    end

  end

  def process
    # if the validation of the data is successful, it will create a payment order and
    # asynchronously add payments to it one by one
  end

  private

  def parse_payment_order_data

  end

end