class Payment::Validate < BaseOperation
  attr_accessor :payment, :initiating_account, :receiving_account

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:payment].blank?)
      add_message :error, 'Payment not found'
      return
    end
  end

  def init
    self.payment = params[:payment]
  end

  def validate
    if payment.blank?
      add_message :error, 'Payment not found'
      return
    end
    if payment.completed?
      add_message :error, 'Payment has already been processed'
      return
    end
  end

  def process
    validate_transfer_viability
    return if has_errors?
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

  protected
  def validate_transfer_viability
    if payment.initiating_account == payment.receiving_account
      add_message :error, 'Initiating and receiving accounts cannot be the same'
      return
    end

    case payment.initiating_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
      when Payment::AccountType::WALLET
      when Payment::AccountType::CARD
    end

    case payment.receiving_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        if payment.payment_type_id == PaymentType.id_for(:debit)
          add_message :error, 'Cannot debit from Company Credits'
          return
        end
      when Payment::AccountType::WALLET
      when Payment::AccountType::CARD
    end
  end

end