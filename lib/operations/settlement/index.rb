class Settlement::Index < Settlement::Base
  attr_accessor :users

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end
  end

  def process
    params[:indirect_associations] = true
    operation = User::Team::Index.new(user, params)
    user_team = operation.run
    unless operation.success?
      self.messages[:error] = operation.messages[:error]
      return
    end
    self.users = user_team.with_balance_sheet.with_roles.only_employees
    if self.users.nil?
      messages[:error] << 'Users not found'
    end
  end

  def success
    params[:users] = self.users
    Settlement::Index::Presenter.new(user, params)
  end

  class Settlement::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :users

    def initialize(user, params)
      super(user, params)
      self.users = params[:users].paginate(page: params[:page], per_page: 30)
    end
  end

end