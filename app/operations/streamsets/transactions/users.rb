class Streamsets::Transactions::Users < BaseOperation
  attr_accessor :users

  def pre_validate

  end

  def init
    op = ::Users::Index.(user, params)
    if op.failure?
      add_message :error, op.messages[:error]
      return
    end
    self.users = op.users
  end

  def success
    params[:users] = self.users
    Streamsets::Transactions::UsersPresenter.new(user, params, messages)
  end

  class Streamsets::Transactions::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :users, :paginated_users

    def init
      self.users = params[:users]
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_users = self.users.paginate(page: page, per_page: per_page)
    end

  end

end