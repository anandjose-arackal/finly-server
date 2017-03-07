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
    team = User::Team::Index.(user, {role_id: role}).team
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def success
    Settlement::ShowActions::ShowPresenter.new(user, params, messages).actions
  end

  class Settlement::ShowActions::ShowPresenter < Settlement::Base::BasePresenter
    attr_accessor :actions

    def init
      self.actions = load_actions
    end

    def load_actions
      actions = {}
      actions[:add_settlement] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.id_for(:reimbursement).to_s)}
      actions[:settle] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.id_for(:settlement))}
      actions[:debt_to_clearance] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.id_for(:deduct_cash_on_hand))}
      actions[:add_cash_advance] = {url: Rails.application.routes.url_helpers.settlements_path(payment_type: PaymentType.id_for(:add_cash_on_hand))}

      actions
    end
  end
end