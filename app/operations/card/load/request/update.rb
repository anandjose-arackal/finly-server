class Card::Load::Request::Update < Card::Load::Request::Base
  attr_accessor :changes

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if params[:id].blank?
      errors << 'Card Request not found'
    end
    if user.blank?
      errors << 'User not found'
    end
    return if has_errors?
    if params[:card_load_request].blank? or ((params[:card_load_request][:amount_attributes].blank? or
        params[:card_load_request][:amount_attributes][:value].blank?) and
        (params[:card_load_request][:note].blank?))
      errors << 'Nothing to update'
    end
  end

  def init
    self.card_load_request = user.controlling_card_load_requests.with_id(params[:id]).first rescue nil
  end

  def authorize
    if self.card_load_request.blank?
      errors << 'You cannot update this request'
      raise_unauthorized_exception
    end
  end

  def subscribe
    before_save self.card_load_request, &method(:generate_comments)
  end

  def process
    unless card_load_request.update_attributes(request_params)
      errors << card_load_request.errors.full_messages
    end
  end

  def post_process
    save_comments
  end

  protected
  def generate_comments(model)
    self.changes = model.changes.merge(model.amount.changes)
  end

  def save_comments
    return unless changes.present?
    changes.each do |key, value|
      next unless value.present? and key.present?
      case key
        when :name
          self.report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_update_id,
                                     updated_field: 'name', updated_from: report.name_was,
                                     updated_to: report.name
        when :policy_id
          self.report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_update_id,
                                     updated_field: 'policy', updated_from: report.policy_id_was,
                                     updated_to: report.policy_id
        else
      end
    end
  end

end