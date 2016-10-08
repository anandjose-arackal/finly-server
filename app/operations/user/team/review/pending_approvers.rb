
# options
# include_controlling_user: true include the current controlling user if the controlling user is not the owner.
# Set to false by default
class User::Team::Review::PendingApprovers < User::Team::Base
  attr_accessor :approvers, :approving_users, :pos

  def pre_validate
    unless user.present?
      'User not found'
    end
  end

  def init
    init_values
    self.pos = 0
  end

  def authorize
    unless mappings.present?
      messages[:error] << 'Mapping not found'
    end
  end

  def validate
    if money_request.blank? and report.blank?
      messages[:error] << 'Error loading the request'
    end
  end

  def process
    load_pending_approvers
    if money_request.present? and money_request.payment_mode_id == PaymentMode.id_for(:card)
      admins = money_request.user.company.admins
      admins.each do |admin|
        add_approver admin, ::UserRole.id_for(:admin), false
      end
    end
  end

  def success
    User::Team::Review::PendingApprovers::Presenter.new(user, approvers: approvers)
  end

  protected
  def load_pending_approvers
    obj = (money_request or report)
    manager = (obj.controlling_for_user or obj.controlling_user)
    manager_role = (obj.controlling_for_user_role_id or obj.controlling_user_role_id)

    if params[:include_controlling_user] and manager and manager_role and manager != obj.user
      add_approver manager, manager_role, true
    end
    if manager == obj.user
      params[:type] = :manager
      manager = User::Team::Approver.(obj.user, params)
      if manager.present?
        manager_role = ::UserRole.id_for(:manager)
        add_approver manager, manager_role, true
      else
        params[:type] = :finance_manager
        manager = User::Team::Approver.(obj.user, params)
        if manager.present?
          manager_role = ::UserRole.id_for(:finance_manager)
          add_approver manager, manager_role, true
        end
      end
    end

    return if manager.blank? or manager_role.blank?

    if manager_role == ::UserRole.id_for(:manager)
      params[:type] = :approves_to
      while manager.present?
        manager = User::Team::Approver.(manager, params)
        add_approver manager, manager_role, true if manager.present?
      end

      manager_role = nil
      params[:type] = :finance_manager
      manager = User::Team::Approver.(obj.user, params)
      if manager.present?
        manager_role = ::UserRole.id_for(:finance_manager)
        add_approver manager, manager_role, true
      end
    end

    params[:type] = :approves_finance_to
    while manager.present?
      manager = User::Team::Approver.(manager, params)
      add_approver manager, manager_role, true if manager.present?
    end
  end

  def add_approver(user, role_id, reviewer)
    return if approving_users.present? and approving_users.include?(user)
    self.pos += 1
    self.approvers = [] if self.approvers.blank?
    self.approvers << {approver: user, role_id: role_id, pos: self.pos, reviewer: reviewer}
    if approving_users.blank?
      approving_users = []
    end
    approving_users << user
  end

  class User::Team::Review::PendingApprovers::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :approvers

    def init
      self.approvers = params[:approvers]
    end

    def approver_with_id(id)
      return nil if self.approvers.blank?
      self.approvers.each do |item|
        if item[:approver].id == id
          return item
        end
      end
    end

    def next_approver
      return nil if self.approvers.blank?
      self.approvers.first
    end

  end

end
