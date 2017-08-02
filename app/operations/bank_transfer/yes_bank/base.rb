class BankTransfer::YesBank::Base < BaseOperation
  attr_accessor :config

  def self.call(config, user, params)
    self.new(user, params).run
  end

  def initialize(user, params)
    super(user, params)
  end

  def authorized_user_types
    [:company_admin]
  end

end