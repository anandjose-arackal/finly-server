class Vendors::PennyTest < Vendors::Base
  attr_accessor :bank_account_params, :account_name

  class Vendors::PennyTest::TestPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :account_name, :match_percentile

    def init
      self.account_name = params[:account_name]
      self.match_percentile = params[:match_percentile]
    end
  end

  def init
    self.bank_account_params = generate_params
  end

  def validate
    if bank_account_params[:account_number].blank? || !validate_ifsc(bank_account_params[:account_number])
      add_message :error, "Please provide a valid bank account number"
    end

    if bank_account_params[:ifsc].blank? || !validate_ifsc(bank_account_params[:ifsc])
      add_message :error, "Please provide a valid ifsc"
    end
  end

  def process
    op = BankTransfer::BankAccounts::CheckValidity.(user, bank_account_params)
    if op.success?
      self.account_name = op.full_name
    else
      add_message :error, op.messages[:error]
    end
  end

  def success
    params[:account_name] = self.account_name
    params[:match_percentile] = self.match_percentile
    Vendors::PennyTest::TestPresenter.new(user, params, messages)
  end

  private

  def generate_params
    params.require(:bank_account).permit(:name, :account_number, :ifsc)
  end

  def valid_bank_account(item)
    pattern = Regexp.new(Constants::VALID_BANK_ACCOUNT)
    if item =~ pattern
      return true
    else
      return false
    end
  end

  def validate_ifsc(item)
    pattern = Regexp.new(Constants::VALID_IFSC)
    if item =~ pattern
      return true
    else
      return false
    end
  end
end