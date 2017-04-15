class Payment::Process < BaseOperation
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
  end

  def validate
    validation = Payment::Validate.(user, payment: self.payment)
    unless validation.success?
      add_message :error, validation.messages[:error]
    end
  end

  def process
    # todo handle other types of payments other than credit meal card, for now we are going with an assumption that this would be called only for crediting meal cards
    action_type = :credit

    case payment.receiving_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        # Unreachable as you cannot credit from card/wallet to virtual_account, this can only be debited

      when Payment::AccountType::WALLET
        

      when Payment::AccountType::CARD

    end

    case payment.initiating_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        if action_type == :credit
          # Do nothing
        end
      when Payment::AccountType::WALLET
        if action_type == :credit
          # Do nothing
        end
      when Payment::AccountType::CARD
        if action_type == :credit
          # Do nothing
        end
    end
  end

  def success
    params[:payment] = self.payment
    Payment::Process::SuccessPresenter.new(user, params, messages)
  end

  class Payment::Process::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

end