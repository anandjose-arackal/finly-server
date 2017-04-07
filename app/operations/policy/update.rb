class Policy::Update < Policy::Base
  attr_accessor :description

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
    self.description = params[:policy][:description] rescue nil
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
    self.policy.update(description: description)
  end

  def post_process
    add_message :success, 'Updated Policy Description'
  end

end