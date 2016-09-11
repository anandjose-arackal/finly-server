class Settlement::Index < Settlement::Base
  attr_accessor :users

  def pre_validate
    unless user.present?
      errors << 'User not found'
    end
  end

  def process
    params[:indirect_associations] = true
    operation = User::Team::Index.new(user, params)
    user_team = operation.run
    unless operation.is_success?
      self.errors = operation.errors
      return
    end
    self.users = user_team.with_balance_sheet.with_roles.only_employees
    if self.users.nil?
      errors << 'Users not found'
    end
  end

  def success
    params[:users] = self.users
    Settlement::Index::Presenter.new(user, params)
  end

  class Settlement::Index::Presenter < BaseOperation::BasePresenter
    attr_accessor :users

    def initialize(user, params)
      super(user, params)
      self.users = params[:users].paginate(page: params[:page], per_page: 30)
    end
  end

end