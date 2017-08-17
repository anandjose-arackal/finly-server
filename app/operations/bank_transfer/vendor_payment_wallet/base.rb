# bunch of this is common for all actions involving a wallet

class BankTransfer::VendorPaymentWallet::Base < BaseOperation

  attr_accessor :initiating_account_type, :initiating_account_id, :initiating_account,
                :receiving_account_type, :receiving_account_id, :receiving_account,
                :amount, :receiving_user

  def authorized_user_types
    if params.present? and params[:initiating_account_type].present? and params[:receiving_account_type].present?
      if params[:initiating_account_type].to_sym == :company_credits or params[:receiving_account_type].to_sym == :company_credits
        return :company_admin
      elsif params[:initiating_account_type].to_sym == :vendor_wallet and params[:receiving_account_type].to_sym == :vendor_wallet
        return [:company_admin, :finance_manager]
      end
    end
    [:finance_manager, :company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
    if params[:initiating_account_id].blank? || params[:initiating_account_type].blank?
      add_message :error, "Initiating account not found"
      return
    end
    if params[:receiving_account_id].blank? || params[:receiving_account_type].blank?
      add_message :error, "Initiating account not found"
      return
    end
    if params[:receiving_user_id].blank?
      add_message :error, "Receiving user not present"
      return
    end
  end

  def init
    self.amount = params[:amount]

    # extracting the receiving user
    # as of now it's unscoped and returns all the company's users,
    # todo - will later be scoped to just the user's team
    self.receiving_user = user.company.users.find_by(id: params[:receiving_user_id])
    # extracting the initiating and receiving accounts

    self.initiating_account_type = params[:initiating_account_type].to_sym
    case initiating_account_type
      when :company_credits
        self.initiating_account = user.company.yes_bank_company_account
      when :vendor_wallet
        self.initiating_account = user.vendor_payment_wallet
      else
        # do nothing?
    end
    case receiving_account_type
      when :company_credits
        self.receiving_account = receiving_user.company.yes_bank_company_account
      when :vendor_wallet
        self.receiving_account = receiving_user.vendor_payment_wallet
      else
        # do nothing?
    end
  end

  def validate
    if params[:password].blank?
      add_message :error, "You need to provide your password for this transfer"
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, "Invalid password"
      return
    end
  end
end