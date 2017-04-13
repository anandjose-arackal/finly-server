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
    case payment.initiating_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        case payment.receiving_account_type
          when Payment::AccountType::VIRTUAL_ACCOUNT

          when Payment::AccountType::WALLET

          when Payment::AccountType::CARD

        end
      when Payment::AccountType::WALLET
        case payment.receiving_account_type
          when Payment::AccountType::VIRTUAL_ACCOUNT

          when Payment::AccountType::WALLET

          when Payment::AccountType::CARD

        end
      when Payment::AccountType::CARD
        case payment.receiving_account_type
          when Payment::AccountType::VIRTUAL_ACCOUNT

          when Payment::AccountType::WALLET

          when Payment::AccountType::CARD

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