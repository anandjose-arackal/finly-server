class MoneyRequest::Base < BaseOperation
  attr_accessor :money_request

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_request = MoneyRequest::Index.(user, params).money_requests.with_id(id).first rescue nil
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
    end
  end

  def success
    params[:money_request] = self.money_request
    MoneyRequest::Base::Presenter.new(user, params, messages)
  end

  def user_role_for_money_request
    if user.id == money_request.user.id
      UserRole.employee_id
    elsif user.manager? and User::Team::IsApprover.(user, {money_request: self.money_request, type: :manager})
      UserRole.manager_id
    elsif user.finance_manager? and User::Team::IsApprover.(user, {money_request: self.money_request, type: :finance_manager})
      UserRole.finance_manager_id
    end
  end

  class MoneyRequest::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request, :items, :manager, :finance_manager, :status, :total, #:money_request_currency,
                  :required_by_date, :comments, :actions, :policies, :selected_policy, :violations, :result

    def init
      self.money_request = params[:money_request]
      self.items = money_request.items
      self.status = money_request.relative_status_name user
      self.total = money_request.total_amount
      self.required_by_date = money_request.required_by_date
      self.comments = money_request.comments
      self.actions = load_actions
      self.policies = money_request.user.policies
      self.selected_policy = money_request.policy
      self.manager = User::Team::Approver.(money_request.user, money_request: self.money_request, type: :manager)
      self.finance_manager = User::Team::Approver.(money_request.user, money_request: self.money_request, type: :finance_manager)
    end

    def load_actions
      actions = {}
      if admin_view?
        if self.money_request.can_take_control? and not self.money_request.controlling_user?(user)
          actions[:take_control] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        elsif self.money_request.processing? and self.money_request.controlling_user?(user)
          if self.money_request.payment_mode_card?
            if user.company_admin?
              actions[:credit_card_from_virtual_account]= {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id,
                                                                                                                        view: params[:view])}
            end
            actions[:credit_card_from_wallet] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id,
                                                                                                              view: params[:view])}
            actions[:approve_and_forward_to] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
          else
            actions[:approve] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
          end
          actions[:reject] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        end
      elsif finance_view? or manager_view?
        if self.money_request.processing? and self.money_request.controlling_user?(user)
          if self.money_request.payment_mode_card?
            actions[:credit_card_from_wallet] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id,
                                                                                                    view: params[:view])}
            actions[:approve_and_forward_to] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
          else
            actions[:approve] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
          end
          actions[:reject] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        elsif (self.money_request.can_unapprove?) and self.money_request.associated_users(self.money_request.controlling_user).include?(user)
          actions[:unapprove] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        end
      else
        if self.money_request.open? or self.money_request.retracted? or self.money_request.rejected?
          actions[:delete] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
          actions[:editable] = {value: true}
          actions[:submit] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        elsif self.money_request.processing?
          actions[:retract] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        end
      end
      actions
    end

    def forwardable_users
      if self.actions.present? and self.actions[:approve_and_forward_to].present?
        users = User::Team::Review::PendingApprovers.(user, money_request: self.money_request).approvers rescue nil
        return nil if users.blank?
        new_users = []
        users.each do |item|
          unless item[:approver].id == user.id
            new_users << item
          end
        end
        return new_users
      end
      nil
    end

  end

end
