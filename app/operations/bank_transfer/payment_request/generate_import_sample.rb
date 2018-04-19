# now that the import should include custom fields that belong to a particular company,
# it will need to be dynamically generated
class BankTransfer::PaymentRequest::GenerateImportSample < BankTransfer::PaymentRequest::Base

  attr_accessor :company, :payment_order_custom_fields, :sample_type,
                :headers, :content, :sheets

  def init
    self.company = user.company
    self.payment_order_custom_fields = self.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    self.sample_type = params[:sample_type]
  end

  def process
    self.headers = default_headers
    self.content = []
    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: []
        }
    ]
    tds_headers = ["ID", "TDS Slab Name", "TDS Rate"]
    tds_contents = []
    current_company.tds_slabs.each do |tds_slab|
      tds_contents << [tds_slab.id, tds_slab.name, tds_slab.tds]
    end
    self.sheets << {
        item_headers: tds_headers,
        item_contents: tds_contents,
        name: "TDS Slabs"
    }
    # TODO - add custom fields in separate sheets / same sheet with different headers
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets}}, messages)
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
       "Tax Rate",
       "Discount Rate",
       "TDS Slab ID",
       "Invoice Number",
       "Invoice Date (dd-mm-yyyy)",
       "Due Date (dd-mm-yyyy)"
    ]
  end

  def tds_slabs

  end
end