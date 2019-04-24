class Vendors::FilterConfig < Vendors::Base
  attr_accessor :vendor_types, :tds_rates,
                :policies, :vendor_statuses
  def init
    self.vendor_types = user.company.vendor_types

    if user.company.vendor_empanelment_workflow_enabled?
      self.vendor_statuses = VendorStatus.all
      filter_role_ids = [UserRole.id_for(:vendor_creator), UserRole.id_for(:vendor_reviewer), UserRole.id_for(:vendor_manager)]
      self.policies = Policy::VendorPayments::Index.(user, {filter_role_id: filter_role_ids}).policies
    end
  end

  def validate
  end

  def success
    params[:vendor_types] = self.vendor_types
    params[:vendor_empanelment_workflow_enabled] = user.company.vendor_empanelment_workflow_enabled?
    if user.company.vendor_empanelment_workflow_enabled?
      params[:vendor_statuses] = self.vendor_statuses
      params[:policies] = self.policies
    end
    Vendors::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Vendors::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendor_types, :policies, :vendor_empanelment_workflow_enabled, :vendor_statuses

    def init
      self.policies = Policy.none
      self.vendor_empanelment_workflow_enabled = params[:vendor_empanelment_workflow_enabled]
      self.vendor_types = params[:vendor_types]
      if user.company.vendor_empanelment_workflow_enabled?
        self.vendor_statuses = params[:vendor_statuses]
        self.policies = params[:policies]
      end
    end
  end
end