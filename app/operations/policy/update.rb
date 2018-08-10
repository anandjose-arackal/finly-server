class Policy::Update < Policy::Base

  def authorized_user_types
    [:admin, :policy_admin]
  end

  def pre_validate
    super
    return if has_errors?
    if params.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    self.policy = Policy::Index.(user, view: params[:view]).policies.with_id((params[:policy_id] or params[:id])).first rescue nil
  end

  def validate
    unless self.policy
      add_message :error, 'Policy not found'
      return
    end
    unless user.policy_admin?(self.policy) or user.company_admin?
      add_message :error, 'You do not have the required permission to update this policy'
    end
  end

  def process
    unless self.policy.update(strong_params)
      add_message :error, self.policy.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Updated Policy Description'
  end

  protected
  def strong_params
    params.require(:policy).permit(:description, :name, :base_currency_id, :settlement_currency_id)
  end

end