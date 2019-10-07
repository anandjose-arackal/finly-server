class Integrations::Tally::BPRVouchers < Integrations::Tally::Base
  attr_accessor :expenses, :payment_tickets, :file_url

  def authorized_user_types
    []
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end

    unless user.company.tally_configuration.present? and
        user.company.tally_configuration.bpr_voucher_enabled and
        user.company.tally_configuration.bpr_voucher_configuration
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end

    if params[:id].blank? and not params[:filtered]
      add_message :error, 'Invoice not found'
      return
    end

    unless user.has_role?(UserRole.id_for(:finance_manager)) or user.has_role?(UserRole.id_for(:admin))
      add_message :error, 'You are not authorized to perform this action'
      return
    end
  end

  def process
    {
        "company_name": "Mohallatech Pvt Ltd",
        "date": "{{payment.date}}",
        "voucher_type": "Payment",
        "reference": "{{payment.reference_id}}",
        "narration": "{{payment.narration}}",
        "beneficiary": {
            "gl_name": "{{payment.vendor.gl_name}}",
        },
        "account": {
            "gl_name": "Kotak",
            "bank_allocations": [
                {
                    "name": "Kotak Bank",
                    "partyname": "{{payment.vendor.gl_name}}",
                    "transactiontype": "Others",
                    "paymentmode": "Transacted",
                    "amount": "{{payment.amount}}"
                },
            ]
        }
    }

    configuration = user.company.tally_configuration.bpr_voucher_configuration&.with_indifferent_access

    payments_presenter = BankTransfer::PaymentRequest::Index.(user, params)
    unless payments_presenter&.success?
      add_message :error, payments_presenter.messages[:error]
      return
    end
    self.payment_tickets = payments_presenter.payment_requests
    if params[:filtered]
      # Todo Completed Only
      self.payment_tickets = self.payment_tickets.processed
    else
      id = params[:id] || params[:payment_id]
      id = id.split(',') if id.is_a?(String)
      self.payment_tickets = self.payment_tickets.with_id(id)
    end

    self.payment_tickets = self.payment_tickets

    company_name = LiquidHelper.interpolate(configuration['company_name'], 'user' => user)
    generator = ::Tally::Generator.new(company_name: company_name)
    payment_tickets.each do |payment_ticket_obj|
      payment_ticket = payment_ticket_obj.to_liquid
      payment_ticket.payments.each do |payment|
        voucher = add_voucher generator, payment_ticket, payment, configuration
        add_beneficiary_ledger voucher, payment_ticket, payment, configuration
        add_payment_ledger voucher, payment_ticket, payment, configuration

        unless voucher.valid?
          add_message :error, voucher.errors.full_messages
          return
        end
      end
    end

    file_data = generator.as_xml
    file = Paperclip::Tempfile.new(['export', '.xml'])
    open(file.path, 'wb') { |f| f.write file_data }
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.day)
    self.file_url = temp_file.file.url
  end

  def success
    Integrations::Tally::Base::FilePresenter.new(user, {file_url: self.file_url}, messages)
  end

  def add_voucher(generator, payment_ticket, payment, configuration)
    voucher_data = LiquidHelper.interpolate(configuration.slice('date', 'voucher_number', 'voucher_type', 'narration', 'reference'), "payment" => payment, "payment_ticket" => payment_ticket)
    beneficiary_data = LiquidHelper.interpolate(configuration['beneficiary'].slice('gl_name'), "payment" => payment, "payment_ticket" => payment_ticket)
    generator.add_voucher(voucher_data.merge(beneficiary_data))
  end

  def add_beneficiary_ledger(voucher, payment_ticket, payment, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['beneficiary'], "payment" => payment, "payment_ticket" => payment_ticket)
    voucher.add ledger_data['gl_name'], payment.amount
  end

  def add_payment_ledger(voucher, payment_ticket, payment, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['account'].slice('gl_name', 'bank_allocations'), "payment" => payment, "payment_ticket" => payment_ticket)
    voucher.add ledger_data['gl_name'], (-payment.amount), bank_allocations: ledger_data['bank_allocations']
  end

end