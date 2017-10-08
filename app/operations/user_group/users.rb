class UserGroup::Users < UserGroup::Base
  attr_accessor :filter_group_items, :selected_users

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.filter_group_items = params[:filter_group_items]
    unless self.filter_group_items.is_a?(Array)
      self.filter_group_items = [self.filter_group_items]
    end
  end

  def validate

  end

  def process
    if self.filter_group_items.present?
      users_op = User::Team::Index.new(user, params)
      result = users_op.run
      unless users_op.success?
        add_message :error, users_op.messages[:error]
        return
      end
      self.selected_users = result
    else
      self.selected_users = User.none
    end
  end

  def success
    params[:selected_users] = self.selected_users
    UserGroup::Users::SuccessPresenter.new(user, params, messages)
  end

  class UserGroup::Users::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_users

    def init
      self.selected_users = params[:selected_users]
    end

  end

end