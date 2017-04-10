class Admin::Users::Base < BaseOperation

  attr_accessor :selected_user

  def success

  end

  class Admin::Users::Base::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :created_user, :selected_user

    def init
      self.created_user = params[:created_user]
      self.selected_user = params[:selected_user]
    end
  end
end