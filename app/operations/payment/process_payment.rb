class Payment::ProcessPayment < BaseOperation
  attr_accessor :payment, :initiating_account, :receiving_account

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:payment].blank? and params[:payment_id].blank?)
      add_message :error, 'Payment not found'
      return
    end
  end

  def init
    self.payment = params[:payment]
    if self.payment.blank?
      self.payment = user.initiating_payments.find_by_id(params[:payment_id])
    end
    if payment.present?
      payment.clear_system_messages
    end
  end

  def validate
    validation = Payment::Validate.(user, payment: self.payment)
    unless validation.success?
      unless payment.completed?
        validation.messages[:error].each do |content|
          payment.system_messages.create content: content, system_message_type_id: SystemMessageType.id_for(:error)
        end
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      end
      add_message :error, validation.messages[:error]
    end
  end

  def process
    # todo handle other types of payments other than credit meal card, for now we are going with an assumption that this would be called only for crediting meal cards
    action_type = :credit

    credit_receiving_user = nil
    credit_receiving_account = nil

    debit_receiving_user = nil
    debit_receiving_account = nil

    case action_type
      when :credit
        credit_receiving_user = payment.receiving_user
        credit_receiving_account = payment.receiving_account

        debit_receiving_user = payment.initiating_user
        debit_receiving_account = payment.initiating_account
      when :debit
        debit_receiving_user = payment.receiving_user
        debit_receiving_account = payment.receiving_account

        credit_receiving_user = payment.initiating_user
        credit_receiving_account = payment.initiating_account
      else
        # Error
    end

    amount = self.payment.amount.value

    case debit_receiving_account.class.name.to_sym
      when Payment::AccountType::VIRTUAL_ACCOUNT
        # Unreachable
      when Payment::AccountType::WALLET
        unless debit_receiving_account.subtract_funds(amount)
          add_message :error, debit_receiving_account.errors.full_messages
        end
      when Payment::AccountType::CARD
        debit_presenter = ItzCash::Debit.(debit_receiving_user, card_id: debit_receiving_account.id, amount: amount)
        unless debit_presenter.success?
          add_message :error, debit_presenter.messages[:error]
        end
    end

    if has_errors?
      self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      return
    end

    case credit_receiving_account.class.name.to_sym
      when Payment::AccountType::VIRTUAL_ACCOUNT
        # Unreachable
      when Payment::AccountType::WALLET
        if action_type == :credit
          unless credit_receiving_account.add_funds(amount)
            add_message :error, credit_receiving_account.errors.full_messages
          end
        end
      when Payment::AccountType::CARD
        if action_type == :credit
          credit_presenter = ItzCash::Credit.(credit_receiving_user, card_id: credit_receiving_account.id, amount: amount)
          unless credit_presenter.success?
            # throw error message saying debit is successful but credit was unsuccessful
            add_message :error, 'Amount could not be credited, the funds will be transferred to your company balance'
          end
        end
    end

    if has_errors?
      self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      return
    end

    self.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
  end

  def success
    params[:payment] = self.payment
    Payment::ProcessPayment::SuccessPresenter.new(user, params, messages)
  end

  def add_message(type, messages)
    res = super
    return res if payment.blank? or payment.completed? or messages.blank?
    messages = [messages] unless messages.is_a?(Array)
    case type
      when :error
        message_type_id = SystemMessageType.id_for(:error)
      when :success
        message_type_id = SystemMessageType.id_for(:success)
      else
        message_type_id = SystemMessageType.id_for(:info)
    end
    messages.each do |message|
      payment.system_messages.create system_message_type_id: message_type_id, content: message
    end
  end

  class Payment::ProcessPayment::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

end