# action that displays the details of the respective settlement for a user
# params:
# user_id or id : id of the user whose details are being viewed
class Settlement::ShowActions < Settlement::Base

  attr_accessor :to_user, :role

  def init
    self.to_user = user.company.users.find_by(id: params[:user_id] || params[:id])
  end

  def authorize
    if user.admin?
      self.role = UserRole.admin_id
    else
      self.role = UserRole.finance_manager_id
    end
    team = User::Team::Show.(user, {role_id: role, indirect_associations: true}).team
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  class Settlement::ShowActions::ShowPresenter < Settlement::Base::BasePresenter
    attr_accessor :actions

    def initialize(user, params)
      self.actions = load_actions
    end

    def load_actions
      actions = {}
      actions[:add_reimbursement] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.reimbursement_id.to_s)}
      actions[:settle] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.settlement_id)}
      actions[:debt_to_clearance] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.debt_clearance_id)}
      actions[:add_cash_advance] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.advance_id)}

      actions
    end
  end

  def success
    actions_presenter = Settlement::ShowActions::ShowPresenter.new(user, params).actions
    actions_presenter
  end
end