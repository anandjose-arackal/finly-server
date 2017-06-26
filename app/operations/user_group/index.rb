class UserGroup::Index < UserGroup::Base
  attr_accessor :user_groups

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.user_groups = user.company.user_groups.include_items
  end

  def validate

  end

  def success
    params[:user_groups] = self.user_groups
    UserGroup::Index::SuccessPresent.new(user, params, messages)
  end

  class UserGroup::Index::SuccessPresent < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user_groups

    def init
      self.user_groups = params[:user_groups]
    end

  end

end