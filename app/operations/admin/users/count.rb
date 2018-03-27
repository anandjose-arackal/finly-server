class Admin::Users::Count < Admin::Users::Base

  attr_accessor :count

  class Admin::Users::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end

  def process
    result = Admin::Users::Index.(user, params)
    if result.success?
      self.count = result.users.count
    else
      add_message :error, op.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Admin::Users::Count::CountPresenter.new(user, params, messages)
  end
end