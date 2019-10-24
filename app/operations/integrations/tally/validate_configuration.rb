class Integrations::Tally::ValidateConfiguration < Integrations::Tally::Base
  attr_accessor :is_configured

  def authorized_user_types
    []
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    tally_configuration = user.company.tally_configuration
    authorized_roles = UserRole.ids_for(
        :admin, :finance_manager, :non_po_initiator, :invoice_auditor,
        :po_invoice_initiator, :po_invoice_reviewer, :po_invoice_auditor,
        :non_po_invoice_initiator, :non_po_invoice_reviewer,
        :non_po_invoice_auditor
    )
    user_roles = user.policy_user_roles.pluck(:user_role_id) + user.role_mapping.pluck(:user_role_id)
    self.is_configured = tally_configuration&.company_name.present? &&
        ((authorized_roles - user_roles).size < authorized_roles.size)
  end

  def success
    params[:is_configured] = !!self.is_configured
    Integrations::Tally::ValidateConfiguration::Presenter.new(user, params)
  end

  class Integrations::Tally::ValidateConfiguration::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :is_configured

    def init
      self.is_configured = params[:is_configured]
    end
  end
end