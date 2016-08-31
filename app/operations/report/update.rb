class Report::Update < Report::Base
  attr_accessor :changes

  def pre_validate
    super
    if params[:name].blank? and params[:policy_id].blank?
      errors << 'Nothing to update'
    end
  end

  def pre_authorize
    unless self.user.present?
      errors << 'User not found'
      raise_unauthorized_exception
    end
  end

  def init

  end

  def authorize
    unless report.controlling_user == user == report.user
      errors << 'Only report owners can update report'
      raise_unauthorized_exception
    end
  end

  def validate
    unless report.retracted? or report.open?
      errors << 'Cannot update report unless retracted'
    end
  end

  def subscribe
    before_save self.report, &method(:generate_comments)
  end

  def process
    param = {}
    param[:name] = params[:name] if params[:name].present? and params[:name] != report.name
    param[:policy_id] = params[:policy_id] if params[:policy_id].present?
    if param[:policy_id].present? and param[:policy_id] == 'nil'
      param[:policy_id] = nil
    end
    return unless param.present?
    unless report.update(param)
      errors << report.errors.full_messages
      false
    end
  end

  def post_process
    save_comments
  end

  protected
  def generate_comments(model)
    self.changes = model.changes
  end

  def save_comments
    return unless changes.present?
    changes.each do |key, value|
      next unless value.present? and key.present?
      case key
        when :name
          self.report.comments.create user: user, comment_action_id: CardLoadRequestCommentAction.update_id,
                                                 updated_field: 'note', updated_from:  value[0], updated_to: value[1]
        when :policy_id
          self.report.comments.create user: user, comment_action_id: CardLoadRequestCommentAction.update_id,
                                                 updated_field: 'amount', updated_from:  value[0], updated_to: value[1]
        else
      end
    end
  end

end