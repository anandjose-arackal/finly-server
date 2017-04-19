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
    validate_balances
    return if has_errors?
  end

  def success
    params[:payment] = self.payment
    Payment::Validate::SuccessPresenter.new(user, params, messages)
  end

  class Payment::Validate::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
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

  def validate_balances
    action_type = :credit

    case payment.receiving_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        # Unreachable
      when Payment::AccountType::WALLET
        if action_type == :debit
          result = User::Balance.(user, target_user: payment.receiving_user, target_user_wallet: true)
          if result.success?
            if result.balances[:target_user][:wallet][:balance] < payment.amount.value
              add_message :error, 'Insufficient amount to initiate the transfer'
            end
          else
            add_message :error, result.messages[:error]
          end
        end
      when Payment::AccountType::CARD
        if action_type == :debit
          result = User::Balance.(user, target_user: payment.receiving_user, target_user_card: true, target_user_card_id: payment.receiving_account.id)
          if result.success?
            if result.balances[:target_user][:card][payment.receiving_account.id][:balance] < payment.amount.value
              add_message :error, 'Insufficient amount to initiate the transfer'
            end
          else
            add_message :error, result.messages[:error]
          end
        end
    end

    case payment.initiating_account_type
      when Payment::AccountType::VIRTUAL_ACCOUNT
        if action_type == :credit
          # todo uncomment, validation was really slow which is why it was removed
          # result = User::Balance.(user, virtual_account: true)
          # if result.success?
          #   balance = result.balances[:virtual_account][:balance]
          #   if balance < payment.amount.value
          #     add_message :error, 'Insufficient amount to initiate the transfer'
          #   end
          # else
          #   add_message :error, result.messages[:error]
          # end
        end
      when Payment::AccountType::WALLET
        if action_type == :credit
          result = User::Balance.(user, current_user_wallet: true)
          if result.success?
            if result.balances[:current_user][:wallet][:balance] < payment.amount.value
              add_message :error, 'Insufficient amount to initiate the transfer'
            end
          else
            add_message :error, result.messages[:error]
          end
        end
      when Payment::AccountType::CARD
        if action_type == :credit
          result = User::Balance.(user, current_user_card: true, current_user_card_id: payment.initiating_account.id)
          if result.success?
            if result.balances[:current_user][:card][payment.initiating_account.id][:balance] < payment.amount.value
              add_message :error, 'Insufficient amount to initiate the transfer'
            end
          else
            add_message :error, result.messages[:error]
          end
        end
    end
  end

end