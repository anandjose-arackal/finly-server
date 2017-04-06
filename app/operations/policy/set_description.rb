class Policy::SetDescription < Policy::Base
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
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id] || params[:id])
  end

  def process
    self.policy.update(description: description)
  end

  def post_process
    add_message :success, 'Updated Policy Description'
  end

end