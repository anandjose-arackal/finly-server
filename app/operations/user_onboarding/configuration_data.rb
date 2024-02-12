class UserOnboarding::ConfigurationData < UserOnboarding::Base
  attr_accessor :user_roles, :policies, :grouped_roles, :document_list, :document_list

  def pre_validate

  end

  def init

    case RequestStore.store[:current_app]
    when 'vp', :vp
      self.user_roles = ::UserRole::VP_ROLES
    when 'em', :em
			self.user_roles = ::UserRole::VALUES_EM

      unless user.company.travel_desk_enabled? # checks to see if client paid for it
        self.user_roles.delete(:travel_manager)
      end
    end
    params[:view] = 'admin'
    self.policies = ::Policy::Index.(user, params).try(:policies)

  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.policies.blank?
      add_message :error, 'Policy not configured. Please configure the policies for your company before inviting users.'
      return
    end
  end

  def pre_process
    # this should be based on what features company has paid for
    #
    case RequestStore.store[:current_app]
    when 'vp', :vp
      # self.document_list = ['purchase_request', 'purchase_order', 'bank_payment_request', 'payment_agreement', 'po_invoice', 'non_po_invoice', 'vendor', 'budget', 'item_master', 'inventory', 'admin']

      self.document_list = []

      self.document_list << 'bank_payment_request'

      if user.company.procurement_enabled?
        self.document_list << 'purchase_order'
        self.document_list << 'po_invoice'
        self.document_list << 'goods'
      end

      if user.company.invoice_to_pay_system_enabled?
        self.document_list << 'non_po_invoice'
      end

      if user.company.procurement_enabled? || user.company.invoice_to_pay_system_enabled?
        self.document_list << 'inventory'
        self.document_list << 'item_master'
      end

      if user.company.vendor_empanelment_workflow_enabled?
        self.document_list << 'vendor'
      end

      if user.company.purchase_requisition_enabled?
        self.document_list << 'purchase_request'
      end

      if user.company.agreement_based_payment_system_enabled?
        self.document_list << 'payment_agreement'
        self.document_list << 'agreement_invoice'
      end

      if user.company.budgeting_system_enabled?
        self.document_list << 'budget'
      end

      if user.company.utility_bills_enabled?
        self.document_list << 'utility_bill_master'
        self.document_list << 'utility_bill'
      end

    when 'em', :em
      self.document_list = []
    end
  end

  def process
    self.grouped_roles = []

    case RequestStore.store[:current_app]
    when 'vp', :vp
      setup_vp_roles
    when 'em', :em
      setup_em_roles
    end

  end

  def success
    params[:user_roles] = self.grouped_roles
    params[:policies] = self.policies
    UserOnboarding::ConfigurationDataPresenter.new(user, params, messages)
  end

  class UserOnboarding::ConfigurationDataPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policies, :user_roles

    def init
      self.policies = params[:policies]
      self.user_roles = params[:user_roles]
    end

  end

  private

  # FE wants data in a format grouped by document
  # 
  # [
  # 	{ :document_name=>"expense_management",
  # 		:document_roles=>
  # 		[
  # 			{:name=>"finance_manager", :id=>2}, {:name=>"manager", :id=>3}
  # 		]
  # 	}
  # ]
  #
  def setup_vp_roles
    document_list.each do |list|
      h = {}
      h[:document_name] = list
      h[:document_name] = 'payment_ticket' if list == 'bank_payment_request'# h[:document_roles] = self.user_roles.keys.map(&:to_s).select {|ur| ur.include? list}
      ss = []
      user_roles.except(:admin, :policy_admin).each do|k, v|
        if k.to_s.starts_with?(list)
          hh = {}
          hh[:name] = k.to_s
				  hh[:id] = v
				  ss << hh
				end
			end

			rename_keys = {"bank_payment_request" => "payment_ticket"}

			rename_keys.each do |k,v|
          ss.each do |s|
            if s[:name].starts_with?(k)
              s[:name] = s[:name].sub k, v
          end
        end
        h[:document_roles] = ss

        next if h[:document_roles].blank?

        self.grouped_roles << h
      end
    end
  end

  def setup_em_roles
    h = {}
    h[:document_name] = 'expense_management'
    ss = []
    self.user_roles.except(:admin, :employee, :purchaser, :receiver).each {|k, v| hh = {}; hh[:name] = k.to_s; hh[:id] = v; ss << hh}
    h[:document_roles] = ss

    self.grouped_roles << h
  end


end