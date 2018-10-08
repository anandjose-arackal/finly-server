class Procurements::Invoices::Templates::Index < Procurements::Invoices::Templates::Base
  attr_accessor :invoices

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.invoices = user.invoices.templates
  end

  def success
    params[:invoices] = self.invoices
    Procurements::Invoices::Templates::Index::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Templates::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoices

    def init
      self.invoices = params[:invoices]
    end

  end

end