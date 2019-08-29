class Integrations::Tally::Vouchers < Integrations::Tally::Base
  attr_accessor :expenses, :invoices, :file_url

  class Integrations::Tally::Vouchers::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end

  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless current_company.tally_configuration.present? and current_company.tally_configuration.active
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end
    if params[:id].blank? and not params[:filtered]
      add_message :error, 'Invoice not found'
      return
    end
  end

  def process
    invoices_presenter = BankTransfer::InwardInvoices::Index.(current_user, params)
    unless invoices_presenter&.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end
    self.invoices = invoices_presenter.invoices
    if params[:filtered]
      self.invoices = self.invoices.processed
    else
      id = params[:id] || params[:invoice_id]
      id = id.split(',')
      self.invoices = self.invoices.with_id(id)
    end

    company_name = LiquidHelper.interpolate(configuration['company_name'], 'user' => user)
    generator = ::Tally::Generator.new(company_name: company_name)
    invoices.each do |invoice_obj|
      invoice = invoice_obj.to_liquid

      voucher = add_voucher generator, invoice, configuration
      add_vendor_ledgers voucher, invoice, configuration
      invoice.line_items.each do |item_obj|
        item = item_obj.to_liquid
        add_item_ledgers voucher, invoice, item, configuration
        add_item_gst_ledgers voucher, invoice, item, configuration
      end

      unless voucher.valid?
        add_message :error, voucher.errors.full_messages
        return
      end

      file_data = generator.as_xml
      file = Paperclip::Tempfile.new(['export', '.xml'])
      open(file.path, 'wb') { |f| f.write file_data }
      temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.day)
      debugger
    end


  end

  def success
    Integrations::Tally::Vouchers::SuccessPresenter.new(user, {file_url: self.file_url}, messages)
  end

  def add_voucher(generator, invoice, configuration)
    voucher_data = LiquidHelper.interpolate(configuration.slice('date', 'state', 'voucher_type', 'narration', 'reference'), "invoice" => invoice)
    vendor_data = LiquidHelper.interpolate(configuration['vendor'].slice('gl_name', 'gstin'), "invoice" => invoice)
    generator.add_voucher(voucher_data.merge(vendor_data))
  end

  def add_vendor_ledgers(voucher, invoice, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['vendor'], "invoice" => invoice)
    voucher.add ledger_data['gl_name'], invoice.net_amount, is_party_ledger: true, bill_allocations: ledger_data['bill_allocations']
  end

  def add_item_ledgers(voucher, invoice, item, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['item'].slice(:gl_name, :category_allocations), "item" => item, "invoice" => invoice)
    voucher.add ledger_data['gl_name'], (-item.taxable_amount), category_allocations: ledger_data['category_allocations']
  end

  def add_item_gst_ledgers(voucher, invoice, item, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['item']['gst_gl'], "item" => item, "invoice" => invoice)
    if item.cgst_amount.present?
      voucher.add ledger_data['cgst'], (-item.cgst_amount)
    end
    if item.sgst_amount.present?
      voucher.add ledger_data['sgst'], (-item.sgst_amount)
    end
    if item.igst_amount.present?
      voucher.add ledger_data['igst'], (-item.igst_amount)
    end
  end


end


