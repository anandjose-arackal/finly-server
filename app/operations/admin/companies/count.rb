class Admin::Companies::Count < Admin::Companies::Base

  attr_accessor :count

  class Admin::Companies::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end

  def process
    result = Admin::Companies::Index.(user, params)
    if result.success?
      self.count = result.companies.count
    else
      add_message :error, op.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Admin::Companies::Count::CountPresenter.new(user, params, messages)
  end
end