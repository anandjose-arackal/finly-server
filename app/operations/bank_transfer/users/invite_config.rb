class BankTransfer::Users::InviteConfig < BankTransfer::Users::Base

  attr_accessor 

  def authorized_user_types
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def process
  
  end

  def success

    BankTransfer::Users::InviteConfig::InviteConfigPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::InviteConfig::InviteConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor 

    def init
    end
  end

end