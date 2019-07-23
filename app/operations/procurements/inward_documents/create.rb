class Procurements::InwardDocuments::Create < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :grn_enabled, :grn_disabled, :srn_enabled, :srn_disabled, :result
  def init
  end

  def validate
    validate_role
  end

  def pre_process
    configuration = user.company.feature_subscription

    self.grn_enabled = configuration.grn_enabled == true
    self.grn_disabled = configuration.grn_enabled == false

    self.srn_enabled = configuration.srn_enabled == true
    self.srn_disabled = configuration.srn_enabled == false
  end

  def process
    if self.grn_enabled && self.srn_disabled
      self.result = Procurements::InwardDocuments::CreateGrn.(user, params)
    elsif self.grn_disabled && self.srn_enabled
      self.result = Procurements::InwardDocuments::CreateSrn.(user, params)
    elsif self.grn_enabled && self.srn_enabled
      self.result = Procurements::InwardDocuments::CreateGrnAndSrn.(user, params)
    else
      add_message :error, "Receipt Note disabled for your company. Please contact your admin or Finly Customer Support."
      return
    end

    self.result.messages.keys.each do |key|
      add_message key, self.result.messages[key]
    end

    if self.result.success?
      self.inward_document = self.result.inward_document
    end
  end

  def success
    params[:inward_document] = self.inward_document
    Procurements::InwardDocuments::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::InwardDocuments::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :inward_document, :items

    def init
      self.inward_document = params[:inward_document]
      self.items = inward_document.items
    end
  end

  private

  def validate_role
    unless user.is_goods_receiver? || user.vendor_payments_admin?
      add_message :error, 'You are not allowed to create this document'
      return
    end
  end
end

