class MoneyRequest::Update < MoneyRequest::Base
  attr_accessor :changes, :update_param

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    required_by_date = params[:money_request][:required_by_date] rescue nil
    if required_by_date.present? and Date.parse(required_by_date) < DateUtils.local_date
      messages[:error] << 'Required by date cannot be older than the current date'
    end
  end

  def init
    super
    return unless self.money_request.present?
    self.update_param = {}
    self.update_param = update_params
    if self.update_param[:policy_id].blank? or ([0, '0', 'nil'].include?(self.update_param[:policy_id]))
      self.update_param[:policy_id] = nil
    end
    if self.update_param[:items_attributes].present?
      self.update_param[:items_attributes].each do |attribute|
        if attribute[:category_id].present?
          attribute[:money_request_item_category_id] = attribute[:category_id]
          attribute[:category_id] = nil
        end
      end
    end

    # Assign IDs to existing mapping and its amount so duplicate entries are
    # not created in accepts_nested_attributes_for
    if self.update_param[:items_attributes].present?
      item_attributes = self.update_param[:items_attributes]
      items = self.money_request.items
      item_attributes.each do |item|
        next unless item[:money_request_item_category_id].present?
        mapping = items.with_money_request_item_category(item[:money_request_item_category_id]).first rescue nil
        next unless mapping.present?
        item[:id] = mapping.id
        if item[:amount_attributes].present?
          item[:amount_attributes][:id] = mapping.amount_id
        end
      end
    end
    if update_param.has_key?(:policy_id) and (update_param[:policy_id].blank? or update_param[:policy_id] == 0) and money_request.user.enforce_policy_enabled?
      policy_id = money_request.user.policies.non_default.first.id rescue nil
      update_param[:policy_id] = policy_id
    end
  end

  def validate
    super
    unless money_request.editable?
      add_message :error, "Money Request cannot be edited at this stage"
      return
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

  # if the amounts are left as blank, they're assumed to be 0
  def pre_process
    update_param[:items_attributes].each do |item|
      unless item[:amount_attributes][:value].present?
        item[:amount_attributes][:value] = 0
      end
    end

    # to support mobile app
    if [1, '1'].include?(update_param[:payment_mode_id]) and update_param[:destination_pocket_id].blank?
      update_param[:destination_pocket_id] = self.money_request.user&.user_pockets&.cash_pockets_only&.first&.id
    end

    if [1, '1'].include?(update_param[:payment_mode_id])
      pocket = self.money_request&.user&.user_pockets.with_id(update_param[:destination_pocket_id])&.first

      update_param&.dig(:items_attributes).each do |item_attr|
        item_attr[:amount_attributes][:currency_id] = pocket.base_currency_id rescue nil
      end
    end
  end

  def process
    original_policy_id = money_request.policy_id
    if money_request.update_attributes(self.update_param)
      updated_policy_id = money_request.policy_id
      if params[:custom_fields].present? or original_policy_id != updated_policy_id
        CustomField::SetFields.(money_request, FieldParentType.id_for(:money_request), custom_fields: params[:custom_fields], save: true, reset_fields: true)
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
        # value.each do |updating_mapping|
        #   # todo test it out and add comments
        # end
      else
      end
    end
  end

  def update_params
    params.require(:money_request).permit(:name, :required_by_date, :memo, :policy_id, :travel_request_id, :payment_mode_id, :destination_pocket_id,
            items_attributes: [:category_id, :money_request_item_category_id, amount_attributes: [:value, :currency_id]])
  end

end
