class ExportManager::Master::PaymentAgreements::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Agreements Export'
  configurable true
  handle :payment_agreements
  screen 'payment_agreements.index'
  system :vp
  validate :fetch_agreements
  attr_accessor :header_collection, :sheets, :sheet_names
  attr_accessor :general_invoice_header, :rental_invoice_header, :security_deposit_header, :beneficiary_header
  attr_accessor :general_invoice_rows, :rental_invoice_rows, :security_deposit_rows, :beneficiary_rows

  section :header do
    attribute :agreement_number
    attribute :title
    attribute :policy
    attribute :agreement_date
    attribute :status
    attribute :execution_date
    attribute :expiration_date
    attribute :never_expire
    attribute :renewal_date
    attribute :renewal_reminder

  end

  section :general_invoice do
    attribute :invoice_number
    attribute :vendor_name
    attribute :vendor_code
    attribute :start_date
    attribute :end_date
    attribute :vendor_gstin
    attribute :department
    attribute :location
    attribute :cost_center
    attribute :billing_type
    attribute :prepaid
    attribute :invoice_frequency
  end

  section :rental_invoice do
    attribute :invoice_number
    attribute :vendor_name
    attribute :vendor_code
    attribute :start_date
    attribute :end_date
    attribute :lock_in_period
    attribute :rent_free_period
    attribute :tenancy_period
    attribute :notice_period
    attribute :square_feet
    attribute :vendor_gstin
    attribute :department
    attribute :location
    attribute :cost_center
  end

  section :item_details do
    attribute :item_description
    attribute :tds_applicable
    attribute :comment
    attribute :item_quantity
    attribute :expected_rate
    attribute :discount
    attribute :taxable_amount
    attribute :tax_rate
    attribute :tax_amount
    attribute :item_total_amount
    attribute :net_payable_amount
    attribute :remaining_amount
  end

  section :security_deposit do
    attribute :security_deposit_vendor_name
    attribute :security_deposit_vendor_code
    attribute :security_deposit_gstin
    attribute :security_deposit_address
    attribute :security_deposit_account_name
    attribute :security_deposit_account_number
    attribute :security_deposit_account_ifsc
    attribute :security_deposit_amount
    attribute :security_deposit_balance_payable
  end

  section :beneficiary do
    attribute :beneficiary_vendor_name
    attribute :beneficiary_vendor_code
    attribute :beneficiary_gstin
    attribute :beneficiary_address
    attribute :beneficiary_account_name
    attribute :beneficiary_account_number
    attribute :beneficiary_account_ifsc
    attribute :beneficiary_payment_status
    attribute :beneficiary_amount
    attribute :beneficiary_tax_type
    attribute :beneficiary_tax_amount
    attribute :beneficiary_balance_payable
  end


  def fetch_agreements
    agreement_presenter = ::PaymentAgreements::Index.(user, params)
    unless agreement_presenter.success?
      add_message :error, agreement_presenter.messages[:error]
      return
    end
    agreement_presenter
  end

  def input
    agreement_presenter = fetch_agreements
    agreements = agreement_presenter.payment_agreements
    rental_agreements = RentalInvoice.where(fixed_periodic_template: [nil, FALSE],payment_agreement_id:  agreements.pluck(:id)).template_invoices
    general_agreements = GeneralInvoice.where(fixed_periodic_template: [nil, FALSE],payment_agreement_id: agreements.pluck(:id)).template_invoices
    rental_agreement_line_items = InvoiceLineItem.where(parent_type: 'RentalInvoice').includes(:category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [ :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {tds_amount: :currency}, :amount]).where(parent_id: rental_agreements.pluck(:id))
    general_agreement_line_items = InvoiceLineItem.where(parent_type: 'GeneralInvoice').includes(:category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [ :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {tds_amount: :currency}, :amount]).where(parent_id: general_agreements.pluck(:id))
    security_deposit_items = SecurityDeposit.where(payment_agreement_id: agreements.pluck(:id))
    beneficiary_items = BeneficiaryPayment.where(payment_agreement_id: agreements.pluck(:id))
    {general_invoice: general_agreement_line_items, rental_invoice: rental_agreement_line_items,security_deposit: security_deposit_items, beneficiary: beneficiary_items }
  end

  def generate_rows
    self.sheet_names=[:general_invoice,:rental_invoice, :security_deposit, :beneficiary]

    self.general_invoice_header =  ExportManager::Builders::Spreadsheet::Header.new
    self.rental_invoice_header =  ExportManager::Builders::Spreadsheet::Header.new
    self.security_deposit_header = ExportManager::Builders::Spreadsheet::Header.new
    self.beneficiary_header = ExportManager::Builders::Spreadsheet::Header.new
    self.general_invoice_rows =[]
    self.rental_invoice_rows = []
    self.security_deposit_rows = []
    self.beneficiary_rows =[]

    self.sheet_names.each do |section_name|
      self.class.sections.each do |section|
        next if [:header,:item_details,section_name].exclude?(section.name)
        next if section.name == :item_details && [:security_deposit, :beneficiary].include?(section_name)
        section.attributes.each do |attr|
          next unless add_field?(attr)
          next if attr.dynamic
          self.send("#{section_name.to_s}_header").add attr.column_name
        end
      end
    end

    self.header_collection={general_invoice: general_invoice_header,
                            rental_invoice: rental_invoice_header,
                            security_deposit: security_deposit_header,
                            beneficiary: beneficiary_header}
    return unless export_job.total_records <= 0

    index = 1
    self.sheet_names.each do |section_name|
    data[section_name].find_each do |record|
        update record: record
        row = ExportManager::Builders::Spreadsheet::Row.new(record: record, header: header)
        self.class.sections.each do |section|
          next if [:header,:item_details,section_name].exclude?(section.name)
          next if section.name == :item_details && [:security_deposit, :beneficiary].include?(section_name)
          section.attributes.each do |attribute|
            next unless add_field?(attribute)
            if attribute.dynamic
              self.send attribute.name, row, record
            else
              value = self.send attribute.name, record
              row.add attribute.column_name, value
            end
          end
        end
        self.send("#{section_name}_rows") << row
        progress_update(index)
      index += 1
    end
    end

    self.sheets = {general_invoice: general_invoice_rows, rental_invoice: rental_invoice_rows, security_deposit: security_deposit_rows, beneficiary: beneficiary_rows}
  end


  def file_name
    case format
    when :csv
      ['export', '.csv']
    when :xls
      ['export', '.xlsx']
    end
  end

  def generate_spreadsheet
    file = Tempfile.new(file_name)
    workbook  = ::WriteXLSX.new(file)
    self.sheets.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)
      headers = self.header_collection[name].list
      contents =[]
      sheet.each do |row|
        contents << row.values&.values
      end
      headers.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end
      contents.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file
  end

  def agreement_number(line_item)
    return line_item.payment_agreement.get_agreement_number if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.get_agreement_number
  end

  def title(line_item)
    return line_item.payment_agreement.title if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.title
  end
  def policy(line_item)
    return line_item.payment_agreement.policy&.name if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.policy&.name
  end
  def agreement_date(line_item)
    return line_item.payment_agreement.agreement_date&.strftime("%d-%b-%y") if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.agreement_date&.strftime("%d-%b-%y")
  end

  def status(line_item)
    return line_item.payment_agreement.status.name&.humanize if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.status.name&.humanize
  end

  def execution_date(line_item)
    return line_item.payment_agreement.execution_date&.strftime("%d-%b-%y") if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.execution_date&.strftime("%d-%b-%y")
  end

  def expiration_date(line_item)
    return line_item.payment_agreement.expiration_date&.strftime("%d-%b-%y") if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.expiration_date&.strftime("%d-%b-%y")
  end

  def never_expire(line_item)
    return line_item.payment_agreement.no_expiration if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    (line_item.parent.payment_agreement.no_expiration ? 'YES' :  'NO')
  end

  def renewal_date(line_item)
    return line_item.payment_agreement.renewal_date&.strftime("%d-%b-%y") if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.renewal_date&.strftime("%d-%b-%y")
  end

  def renewal_reminder(line_item)
    return line_item.payment_agreement.renewal_reminder_date&.strftime("%d-%b-%y") if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.payment_agreement.renewal_reminder_date&.strftime("%d-%b-%y")
  end

  def invoice_number(line_item)
    line_item.parent.invoice_number
  end

  def vendor_name(line_item)
    line_item.parent.vendor.display_name
  end

  def vendor_code(line_item)
    line_item.parent.vendor.vendor_id
  end

  def start_date(line_item)
    line_item.parent.start_date&.strftime("%d-%b-%y")
  end

  def end_date(line_item)
    line_item.parent.end_date&.strftime("%d-%b-%y")
  end

  def vendor_gstin(line_item)
    line_item.parent.vendor_location&.gstin
  end

  def department(line_item)
    line_item.parent.department.name
  end

  def location(line_item)
    line_item.parent.location.name
  end

  def cost_center(line_item)
    line_item.parent.cost_center.name
  end

  def billing_type(line_item)
    line_item.parent.billing_type.name
  end

  def prepaid(line_item)
    (line_item.parent.prepaid  ? 'YES' : 'NO')
  end

  def invoice_frequency(line_item)
    line_item.parent.get_invoice_frequency_attributes[:number]
  end

  def lock_in_period(line_item)
    line_item.parent.lock_in_period
  end

  def rent_free_period(line_item)
    line_item.parent.rent_free_period
  end

  def tenancy_period(line_item)
    line_item.parent.tenancy_period
  end

  def notice_period(line_item)
    line_item.parent.notice_period
  end

  def square_feet(line_item)
    line_item.parent.square_feet
  end

  def item_description(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.description
  end
  def tds_applicable(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    (line_item.tds_applicable? ? 'YES' : 'NO')
  end
  def comment(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.comment
  end
  def item_quantity(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.quantity
  end
  def expected_rate(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.rate
  end
  def discount(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.discount
  end
  def taxable_amount(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.taxable_amount&.value
  end
  def tax_rate(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.tax_rate&.rate
  end
  def tax_amount(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.tax_amount&.value

  end
  def item_total_amount(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.net_amount&.value
  end

  def net_payable_amount(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.net_amount&.value
  end

  def remaining_amount(line_item)
    return '' if [SecurityDeposit, BeneficiaryPayment].include?(line_item.class)
    line_item.parent.balance_due&.value
  end

  def security_deposit_vendor_name(security_deposit)
    security_deposit.vendor.display_name
  end

  def security_deposit_vendor_code(security_deposit)
    security_deposit.vendor.vendor_id
  end

  def security_deposit_gstin(security_deposit)
    security_deposit.vendor_location&.gstin
  end

  def security_deposit_address(security_deposit)
    security_deposit.vendor_location&.address
  end

  def security_deposit_account_name(security_deposit)
    security_deposit.bank_account&.name
  end

  def security_deposit_account_number(security_deposit)
    security_deposit.bank_account&.account_number
  end

  def security_deposit_account_ifsc(security_deposit)
    security_deposit.bank_account&.ifsc
  end

  def security_deposit_amount(security_deposit)
    security_deposit.original_amount&.value
  end

  def security_deposit_balance_payable(security_deposit)
    security_deposit.payable_amount&.value
  end

  def beneficiary_vendor_name(beneficiary)
    beneficiary.vendor.display_name
  end

  def beneficiary_vendor_code(beneficiary)
    beneficiary.vendor.vendor_id
  end

  def beneficiary_gstin(beneficiary)
    beneficiary.vendor_location&.gstin
  end

  def beneficiary_address(beneficiary)
    beneficiary.vendor_location&.address
  end

  def beneficiary_account_name(beneficiary)
    beneficiary.bank_account&.name
  end

  def beneficiary_account_number(beneficiary)
    beneficiary.bank_account&.account_number
  end

  def beneficiary_account_ifsc(beneficiary)
    beneficiary.bank_account&.ifsc
  end

  def beneficiary_amount(beneficiary)
    beneficiary.original_amount&.value
  end

  def beneficiary_payment_status(beneficiary)
    beneficiary.status&.name&.humanize
  end

  def beneficiary_tax_type(beneficiary)
    beneficiary.gst_type&.name&.humanize
  end

  def beneficiary_tax_amount(beneficiary)
    beneficiary.tax_amount&.value
  end

  def beneficiary_balance_payable(beneficiary)
    beneficiary.payable_amount&.value
  end

end