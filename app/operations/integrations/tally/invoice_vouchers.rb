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
      add_message :error, 'Report not found'
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

      return on_error(options, :base, voucher.errors.full_messages) unless voucher.valid?
    end

    set_file_data options, generator.as_xml
  end

  def success
    Integrations::Tally::Vouchers::SuccessPresenter.new(user, {file_url: self.file_url}, messages)
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end


