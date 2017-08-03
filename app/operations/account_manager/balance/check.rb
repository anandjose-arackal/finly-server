class AccountManager::Balance::Check < AccountManager::Base

  attr_accessor :for_account, :params, :adapter, :balance

  def self.call(for_account, params = {})
    self.new(for_account, params).run
  end

  def initialize(for_account, params = {})
    super()
    self.for_account = for_account
    self.params = (params or {})
  end

  def pre_validate
    if for_account.blank?
      add_message :error, 'Account not found'
    end
  end

  def init
    self.adapter = retrieve_adapter for_account
  end

  def validate
    if self.adapter.blank? or self.adapter.is_a?(AccountManager::OutsideFinly::OutsideFinlyAdapter)
      add_message :error, 'Error processing balance. Adapter not found'
      return
    end
  end

  def process
    self.balance = self.adapter.balance
    unless self.adapter.valid?
      add_message :error, self.adapter.errors
    end
  end

  def success
    params[:for_account] = self.for_account
    params[:balance] = self.balance
    AccountManager::Balance::Check::SuccessPresenter.new(user, params, messages)
  end

  class AccountManager::Balance::Check::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :for_account, :balance

    def init
      self.for_account = params[:for_account]
      self.balance = params[:balance]
    end

  end

end