class Vendors::NewVendorConfig < Vendors::Base
  attr_accessor :states, :vendor_types, :payment_terms, :currencies, :tds_rates,
                :field_configurations, :policies
  def init
    self.states = GstStateCode.all
    self.vendor_types = user.company.vendor_types
    self.currencies = Currency.all
    self.payment_terms = user.company.payment_terms
    self.tds_rates = user.company.tds_slabs
    self.field_configurations = current_company.field_configurations.with_parent_type(FieldParentType.id_for(:vendor))

    if user.company.vendor_empanelment_workflow_enabled?
      self.policies = Policy::VendorPayments::Index.(user, {filter_role_id: [UserRole.id_for(:vendor_creator)]}).policies
    end
  end

  def validate
  end

  def success
    params[:states] = self.states
    params[:vendor_types] = self.vendor_types
    params[:payment_terms] = self.payment_terms
    params[:currencies] = self.currencies
    params[:tds_rates] = self.tds_rates
    params[:field_configurations] = self.field_configurations
    if user.company.vendor_empanelment_workflow_enabled?
      params[:policies] = self.policies
    end
    Vendors::NewVendorConfig::ConfigPresenter.new(user, params, messages)
  end

  class Vendors::NewVendorConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :states, :vendor_types, :currencies, :payment_terms, :tds_rates, :field_configurations, :policies, :actions, :reviewal_chains

    def init
      self.actions = {
        create: {name: "Create"}
      }
      self.policies = Policy.none
      self.states = params[:states]
      self.vendor_types = params[:vendor_types]
      self.currencies = params[:currencies]
      self.payment_terms = params[:payment_terms]
      self.tds_rates = params[:tds_rates]
      self.field_configurations = params[:field_configurations]
      if user.company.vendor_empanelment_workflow_enabled?
        self.actions[:create] = {name: "Submit for Approval"}
        self.reviewal_chains = []
        self.policies = params[:policies]

        params[:provider_name] = "YesBankVendorProvider"
        policies.each do |policy|
          params[:policy_id] = policy.id
          chain = {
              policy_id: policy.id,
              reviewal_chain: get_reviewal_chain
          }
          self.reviewal_chains.push(chain)
        end
      end
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      if op.success?
        return op.chain
      else
        return nil
      end
    end
  end
end