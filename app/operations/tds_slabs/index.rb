class TdsSlabs::Index < TdsSlabs::Base

  attr_accessor :tds_slabs

  class TdsSlabs::Index::TdsSlabsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :tds_slabs

    def init
      self.tds_slabs = params[:tds_slabs]
    end
  end

  def user_model
    [User, AdminUser]
  end

  def process
    self.tds_slabs = company.tds_slabs
  end

  def success
    params[:tds_slabs] = self.tds_slabs
    TdsSlabs::Index::TdsSlabsPresenter.new(user, params, messages)
  end
end