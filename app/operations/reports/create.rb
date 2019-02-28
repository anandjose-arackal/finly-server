# params:
# name: optional, if creating a report with a name
# expense_ids: ids of the expenses that the report is to be created with
# expenses: array of expense objects to be added to the report

class Reports::Create < Reports::Base
  attr_accessor :for_user, :policy_id, :expenses

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    self.for_user = (params[:for_user] or user)
    return if for_user.blank?
    self.policy_id = params[:policy_id]
    if policy_id.blank? and for_user.enforce_policy_enabled?
      self.policy_id = for_user.policies.non_deleted.non_default&.first&.id
    end
    if policy_id.blank?
      self.policy_id = user.company.default_policy.id
    end
    self.expenses = params[:expenses] || (for_user.expenses.where(id: params[:expense_ids].split(',')) rescue [])
  end

  def authorize
    if policy_id.present? and for_user.policies.non_deleted.with_id(policy_id).blank?
      add_message :error, 'User does not belong to the selected policy'
      raise_unauthorized_exception
    end
  end

  def validate
    if expenses.present?
      expenses.each do |expense|
        if expense.personal
          add_message :error, "Personal expenses cannot be added to reports"
          return
        end
      end
    end

    # mark the respective expenses that are from cash on hand as blocked
    # so that we can raise the rest as violations inside a report
    policy = Policy.find_by(id: self.policy_id)
    unless expenses.is_a?(ActiveRecord::Relation)
      ids = []
      expenses.each do |expense|
        ids << expense.id
      end
      self.expenses = Expense.where(id: ids)
    end
    expenses.spent_from_cash_on_hand.each do |expense|
      if expense.cash_on_hand_blocked
        next
      end
      cash_pocket = expense.spent_from
      if cash_pocket.present? && cash_pocket.cash_pocket?
        cash_pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(cash_pocket)
        amount = expense.calculate_amount_value(policy)
        if cash_pocket_adapter.balance(display_balance: true) >= amount
          expense.update(cash_on_hand_blocked: true)
        end
      end
    end
  end

  def process
    role_id = UserRole.id_for(:employee)
    # If user is delegated to perform actions on behalf of other user
    delegated_action_user = actual_current_user.present? ? actual_current_user : nil
    self.report = for_user.reports.build report_status_id: ReportStatus.open_id,
                                         controlling_user: for_user,
                                         controlling_user_role_id: role_id,
                                         policy_id: policy_id,
                                         travel_request_id: params[:travel_request_id],
                                         name: params[:name],
                                         created_by: delegated_action_user
    report.skip_customizable_validation = true # As validation breaks the creation and loading of report, prevent it during creation
    if report.save
      # report.tracks.create action_user: for_user,
      #                      action_user_role_id: role_id,
      #                      modified_user: for_user,
      #                      modified_user_role_id: role_id,
      #                      report_tracking_action_id: ReportTrackingAction.id_for(:create),
      #                      report_status_id: ReportStatus.open_id,
      #                      delegated_action_user: delegated_action_user
      report.trails.create action_user: for_user,
                           action_id: TrailAction.id_for(:create),
                           action_user_role_id: role_id

      expenses = params[:expenses]
      expense_ids = nil

      if params[:expense_ids] and expenses.blank?
        expense_ids = params[:expense_ids].split(',')
      end

      if expense_ids.present? or expenses.present?
        Reports::Expenses::Add.(user, {for_user: for_user, report: report, expenses: expenses, expense_ids: expense_ids})
      end

      CustomField::SetFields.(report, FieldParentType.id_for(:report), reset_fields: true, save: true)

      # Create Document Level Reviewer Mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.report.reload

      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
        return
      end

    else
      add_message :error, report.errors.full_messages
    end
  end

  def post_process
    if actual_current_user.present?
      report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_created_by_delegate), delegated_action_user: actual_current_user
    end
    add_message :success, 'Report created'
  end

  # def success
  #   params[:report] = self.report
  #   Reports::Create::SuccessPresenter.new(user, params, messages)
  # end
  #
  # class Reports::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
  #   attr_accessor :report
  #
  #   def init
  #     self.report = params[:report]
  #   end
  #
  # end

end