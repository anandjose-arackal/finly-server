class Integration::TallyController < BaseControllers::WebBase

  set_tokens_in_header :vouchers, :reimbursements

  def set_configuration
    @result = Integrations::Tally::SetConfiguration.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def vouchers
    # @result = Integrations::Tally::Vouchers.(current_user, params)
    case params[:type]
    when :vp_invoice_vouchers
      @result = Integrations::Tally::InvoiceVouchers.(current_user, params)
    else
      @result = Integrations::Tally::Vouchers.(current_user, params)
    end
    respond
  end

  def reimbursements
    @result = Integrations::Tally::Reimbursements.(current_user, params)
    respond
  end

  def check
    @result = Integrations::Tally::ValidateConfiguration.(current_user, params)
    @result.messages = {}
    respond
  end

  def export
    params[:export_format] = :xls
    case params[:type]
    when 'vp_invoice_vouchers'
      @result = Integrations::Tally::InvoiceVouchers.(current_user, params)
    when 'vp_bpr_vouchers'
      @result = Integrations::Tally::BPRVouchers.(current_user, params)
    else
      @result = Integrations::Tally::Vouchers.(current_user, params)
    end
    # @result = Integrations::Tally::Vouchers.(current_user, params)
    respond
  end

end
