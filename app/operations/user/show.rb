class User::Show < User::Base
  attr_accessor :selected_user

  def pre_validate
    unless user.present?
      errors << 'User not found'
    end
  end

  def process
    if personal_view?
      self.selected_user = user
    else
      id = (params[:id] or params[:user_id])
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.is_success?
        self.selected_user = result.with_id(id).first rescue nil
        errors << 'User not found' if self.selected_user.blank?
      else
        errors << operation.errors
      end
    end
  end

  def success
    User::Show::Presenter.new(selected_user, params)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter
    attr_accessor :mapping, :managers, :finance_managers, :policies

    def initialize(user, params)
      super(user, params)
      self.mapping = user.team_mapping
      self.policies = user.policies
    end

  end
end