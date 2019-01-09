class User::DelegateMappings::Index < User::DelegateMappings::Base
  attr_accessor :user_delegates

  def process
    unless actual_current_user.present?
      user_ids = current_user.user_delegate_mappings.pluck(:delegate_for_user_id).compact
    else
      user_ids = actual_current_user.user_delegate_mappings.pluck(:delegate_for_user_id).compact
    end
    self.user_delegates = User.with_id(user_ids).with_company_id(self.user.company_id)
  end

  def success
    params[:user_delegates] = self.user_delegates
    User::DelegateMappings::Index::Presenter.new(user, params, messages)
  end

  class User::DelegateMappings::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user_delegates

    def init
      self.user_delegates = params[:user_delegates]
    end
  end


end
