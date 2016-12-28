class ItzCash::VirtualAccountBalance < ItzCash::Base

  def pre_validate
    super
    if user.blank?
      add_message :error, 'User not found'
    end
    if user.company.d_code.blank?
      add_message :error, 'Error loading company configuration. Unable to check balance'
    end
  end

  def env_key
    'itzcash_corporate_balance'
  end

  def post_params
    dcode = user.company.d_code
    itzmodule = Constants::ItzCash::MODULE
    {dcode: dcode, itzmodule: itzmodule}
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:d_code] = parsed_response[1]
    params[:wallets_count] = parsed_response[2].to_i
    params[:wallets] = []
    params[:wallets_count].times do |pos|
      name = parsed_response[(3 + (3 * pos))]
      balance = parsed_response[(4+(3*pos))].to_d
      account_number = parsed_response[(5+(3*pos))].to_d rescue nil
      params[:wallets][pos] = {name: name, balance: balance, account_number: account_number}
    end
    ItzCash::VirtualAccountBalance::SuccessPresenter.new(user, params, messages)
  end

  class ItzCash::VirtualAccountBalance::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :d_code, :wallets_count, :wallets

    def init
      self.response_code = params[:response_code]
      self.d_code = params[:d_code]
      self.wallets_count = params[:wallets_count]
      self.wallets = params[:wallets]
    end

  end

end