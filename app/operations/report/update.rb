# action that updates the report - name or policy update.
class Report::Update < Report::Base
  attr_accessor :changes, :update_param

  def pre_validate
    super
    if params[:name].blank? and params[:policy_id].blank?
      messages[:error] << 'Nothing to update'
    end
  end

  def pre_authorize
    unless self.user.present?
      messages[:error] << 'User not found'
      raise_unauthorized_exception
    end
  end

  def init
    super
    self.update_param = {}
    self.update_param = self.params.permit(:name, :policy_id)
    if self.update_param[:policy_id].present? and self.update_param[:policy_id] == 'nil'
      self.update_param[:policy_id] = nil
    end
  end

  def authorize
    unless user == report.user
      messages[:error] << 'Only report owners can update report'
      raise_unauthorized_exception
    end
    unless user == report.controlling_user
      messages[:error] << 'Only report owners can update report'
      raise_unauthorized_exception
    end
  end

  def validate
    unless report.retracted? or report.open?
      messages[:error] << 'Cannot update report unless retracted'
    end
  end

  def subscribe
    before_save self.report, &method(:generate_comments)
  end

  def process
    return unless update_param.present?
    unless report.update(update_param)
      messages[:error] << report.errors.full_messages
      false
    end
  end

  def post_process
    save_comments
    messages[:success] << "Report updated."
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
          query << {user: user, report_comment_action_id: ReportCommentAction.report_update_id,
                    updated_field: 'name', updated_from: value[0], updated_to: value[1]}
        when :policy_id
          from = to = nil
          from = Policy.with_id(value[0]).first.name rescue nil if value[0].present?
          to = Policy.with_id(value[1]).first.name rescue nil if value[1].present?
          query << {user: user, report_comment_action_id: ReportCommentAction.report_update_id,
                    updated_field: 'policy', updated_from: from, updated_to: to}
        else
      end
    end
    report.comments.create query if query.present?
  end

end