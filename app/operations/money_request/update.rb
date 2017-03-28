class MoneyRequest::Update < MoneyRequest::Base
  attr_accessor :changes, :update_param

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    required_by_date = params[:money_request][:required_by_date] rescue nil
    if required_by_date.present? and Date.parse(required_by_date) < DateUtils.local_date
      messages[:error] << 'Invalid Required By Date'
    end
  end

  def init
    super
    self.update_param = {}
    self.update_param = update_params
    if self.update_param[:policy_id].blank? or self.update_param[:policy_id] == 'nil'
      self.update_param[:policy_id] = nil
    end
    # Assign IDs to existing mapping and its amount so duplicate entries are
    # not created in accepts_nested_attributes_for
    if self.update_param[:items_attributes].present?
      item_attributes = self.update_param[:items_attributes]
      items = self.money_request.items
      item_attributes.each do |item|
        next unless item[:category_id].present?
        mapping = items.with_category(item[:category_id]).first rescue nil
        next unless mapping.present?
        item[:id] = mapping.id
        if item[:amount_attributes].present?
          item[:amount_attributes][:id] = mapping.amount_id
        end
      end
    end
  end

  def authorize
    if self.money_request.blank?
      messages[:error] << 'You cannot update this request'
      raise_unauthorized_exception
    end
  end

  def subscribe
    before_save self.money_request, &method(:generate_comments)
  end

  def process
    if money_request.update_attributes(self.update_param)
      if params[:money_request].present? and params[:money_request][:custom_fields].present?
        CustomField::SetFields.(money_request, FieldParentType.id_for(:money_request), custom_fields: params[:money_request][:custom_fields])
      end
    else
      messages[:error] = money_request.errors.full_messages
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
        self.money_request.comments.create user: user, money_request_comment_action_id: MoneyRequestCommentAction.id_for(:update),
          updated_field: 'name', updated_from: money_request.name_was,
          updated_to: money_request.name
      when :policy_id
        self.money_request.comments.create user: user, money_request_comment_action_id: MoneyRequestCommentAction.id_for(:update),
          updated_field: 'policy', updated_from: money_request.policy_id_was,
          updated_to: money_request.policy_id
      when :items_attributes
        value.each do |updating_mapping|
          # todo test it out and add comments
        end
      else
      end
    end
  end

  def update_params
    params.require(:money_request)
    .permit(:name, :required_by_date, :memo, :policy_id, :payment_mode_id,
            items_attributes: [:category_id, amount_attributes: [:value, :currency_id]])
  end

end
