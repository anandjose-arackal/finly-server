# action that updates the report - name or policy update.
class Reports::Update < Reports::Base
  attr_accessor :changes, :update_param

  def pre_validate
    super
  end

  def pre_authorize
    unless self.user.present?
      messages[:error] << 'User not found'
      raise_unauthorized_exception
    end
  end

  def init
    super
    if self.report.blank?
      id = (params[:id] or params[:report_id])
      self.report = user.controlling_reports.with_id(id).first rescue nil
    end
    self.update_param = {}
    self.update_param = self.params.permit(:name, :policy_id, :memo, :travel_request_id)
    if self.update_param[:policy_id].present? and ([0, '0', 'nil'].include?(self.update_param[:policy_id]))
      self.update_param[:policy_id] = nil
    end
    if update_param.has_key?(:policy_id) and (update_param[:policy_id].blank? or update_param[:policy_id] == 0) and report.user.enforce_policy_enabled?
      policy_id = report.user.policies.non_default.first.id rescue nil
      update_param[:policy_id] = policy_id
    end
  end

  def authorize
    # unless user == report.user
    #   messages[:error] << 'Only report owners can update report'
    #   raise_unauthorized_exception
    # end
    unless user == report.controlling_user
      messages[:error] << 'You cannot edit the report at this stage'
      raise_unauthorized_exception
    end
  end

  def validate
    unless report.retracted? or report.open? or report.rejected? or report.processing?
      messages[:error] << 'You cannot edit the report at this stage'
    end
  end

  def subscribe
    before_save self.report, &method(:generate_comments)
  end

  def process
    original_policy_id = report.policy_id
    if report.update_attributes(update_param)
      updated_policy_id = report.policy_id
      if params[:custom_fields].present? or original_policy_id != updated_policy_id
        CustomField::SetFields.(report, FieldParentType.id_for(:report), custom_fields: params[:custom_fields], save: true, reset_fields: true)
      end
    else
      messages[:error] = report.errors.full_messages
      false
    end
  end

  def post_process
    save_comments
    calculate_amounts # this method recalculates the amoutns for the various Distance/Time/Per Diem expenses
    messages[:success] << 'Report updated'
  end

  protected
  def generate_comments(model)
    self.changes = model.changes
  end

  def save_comments
    return unless changes.present?
    query = []
    changes.each do |key, value|
      next unless value.present? and key.present?
      case key
        when :name
          query << {user: user, report_comment_action_id: ReportCommentAction.id_for(:report_update),
                    updated_field: 'name', updated_from: value[0], updated_to: value[1]}
        when :policy_id
          from = to = nil
          from = Policy.with_id(value[0]).first.name rescue nil if value[0].present?
          to = Policy.with_id(value[1]).first.name rescue nil if value[1].present?
          query << {user: user, report_comment_action_id: ReportCommentAction.id_for(:report_update_id),
                    updated_field: 'policy', updated_from: from, updated_to: to}
        else
      end
    end
    report.comments.create query if query.present?
  end

  def calculate_amounts
    report.expenses.each do |expense|
      if expense.distance_expense? || expense.time_expense? || expense.per_diem_expense?
        expense.amount.update(value: expense.calculate_amount_value(report.policy), currency_id: expense.report.policy.base_currency_id)
      end
    end
  end

end