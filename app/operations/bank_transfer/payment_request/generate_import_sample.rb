# now that the import should include custom fields that belong to a particular company,
# it will need to be dynamically generated
class BankTransfer::PaymentRequest::GenerateImportSample < BankTransfer::PaymentRequest::Base

  attr_accessor :company, :payment_order_custom_fields, :sample_type,
                :headers, :content

  def init
    self.company = user.company
    self.payment_order_custom_fields = self.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    self.sample_type = params[:sample_type]
  end

  def process
    self.headers = default_headers
    self.content = []
    if self.payment_order_custom_fields.empty?
      return
    else
      self.headers += self.payment_order_custom_fields.pluck(:field_name)
    end
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content}}, messages)
  end

  private

  def default_headers
    [
       "Name",
       "Account Number",
       "IFSC",
       "Sub Total",
       "Inclusive of Taxes? (Y/N)",
       "GST Type (1 - IGST ; 2 - CGST/SGST)",
       "Tax Type (1 - Rate ; 2 - Absolute)",
       "Tax",
       "Discount Type (1 - Rate ; 2 - Absolute)",
       "Discount",
       "TDS Type (1 - Rate ; 2 - Absolute)",
       "TDS",
       "Invoice Number",
       "Invoice Date (dd-mm-yyyy)",
       "Due Date (dd-mm-yyyy)"
    ]
  end
end