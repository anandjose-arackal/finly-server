class User::AllUsers < User::Base

  attr_accessor :users

  class User::AllUsers::AllUsersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users

    def init
      self.users = params[:users]
    end

  end

  def authorized_user_types
    [:company_admin]
  end

  def process
    self.users = current_company.users.active
  end

  def success
    params[:users] = self.users
    User::AllUsers::AllUsersPresenter.new(user, params, messages)
  end
end