class Company::Users < Company::Base

  attr_accessor :users

  class Company::Users::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users

    has_scope :filter_search

    def init
      self.users = params[:users]
      self.users = apply_scopes(self.users, params)
    end
  end

  def init
    self.users = user.company.users.with_subscription(RequestStoreUtil.current_app).active
  end

  def success
    params[:users] = self.users
    Company::Users::UsersPresenter.new(user, params, messages)
  end
end