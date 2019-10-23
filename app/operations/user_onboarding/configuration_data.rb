class UserOnboarding::ConfigurationData < UserOnboarding::Base
	attr_accessor :user_roles, :policies, :grouped_roles, :document_list, :document_list
	
	def pre_validate

	end

	def init

		case RequestStore.store[:current_app]
    when 'vp', :vp
			self.user_roles = UserRoles::VALUES_VP
			self.policies = ::Policy::VendorPayments::Index.(user, params).try(:policies)
    when 'em', :em
			self.user_roles = UserRoles::VALUES_EM
			self.policies = ::Policy::VendorPayments::Index.(user, params).try(:policies)
    end
    	
	end

	def validate
		if self.policies.blank?
			add_message :error, 'Policy not configured. Please configure the policies for your company before inviting users.'
			return
		end
	end

	def pre_process

		case RequestStore.store[:current_app]
    when 'vp', :vp
			self.document_list = ['purchase_request', 'purchase_order', 'bank_payment_request', 'payment_agreement', 'po_invoice', 'non_po_invoice', 'vendor', 'budget', 'item_master', 'inventory', 'admin']
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

  def setup_vp_roles
  	document_list.each do |list|
			h = {}
			h[:document_name] = list
			h[:document_roles] = self.user_roles.keys.map(&:to_s).select {|ur| ur.include? list}

			next if h[:document_roles].blank?

			self.grouped_roles << h
		end
  end

  def setup_em_roles
  	h = {}
  	h[:document_name] = 'expense_management'
  	h[:document_roles] = self.user_roles.except(:employee, :purchaser, :receiver).keys.map(&:to_s)
  	
  	self.grouped_roles << h
	end


end