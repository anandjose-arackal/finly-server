class Procurements::Configs::Terms::Index < Procurements::Configs::Terms::Base
  attr_accessor :terms
  def init
    self.terms = user.company.procurement_terms
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def success
    params[:terms] = self.terms
    Procurements::Configs::Terms::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Configs::Terms::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :terms
    def init
      self.terms = params[:terms]
    end
  end
end