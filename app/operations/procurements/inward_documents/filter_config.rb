class Procurements::InwardDocuments::FilterConfig < Procurements::InwardDocuments::Base

  attr_accessor :policies


  def pre_validate
    if user.blank?
      add_message :error, "No user found, try again"
      return
    end
  end

  def init
  end

  def validate
  end

  def process
    self.policies = Policy::VendorPayments::Index.(user, params).policies
  end

  def success
    params[:policies] = self.policies
    Procurements::InwardDocuments::FilterConfig::FilterPresenter.new(user, params, messages)
  end

  class Procurements::InwardDocuments::FilterConfig::FilterPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policies

    def init
      self.policies = params[:policies]
    end
  end
end