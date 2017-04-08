class AdminOperations::User::Base < BaseOperation

  class AdminOperations::User::Base::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :created_user

    def init
      self.created_user = params[:crrated_user]
    end
  end
end