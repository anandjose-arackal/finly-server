class Policy::Mappings::Destroy < Policy::Base
  attr_accessor :updating_mapping, :policy

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed.'
    end
    unless params[:mapping_id].present?
      messages[:error] << 'Nothing to remove'
    end
  end

  # def pre_authorize
  #   user_id = (params[:id] or params[:user_id])
  #   if user.company_admin?
  #     self.updating_user = user.company.users.with_id(user_id).first rescue nil
  #   elsif user.policy_admin?
  #     if params[:user_manager_mapping].present?
  #       admin_policy_id = user.admin_policies.pluck(:id)
  #       params[:user_manager_mapping].each do |key, mapping|
  #         unless admin_policy_id.include?(mapping[:mapping_id])
  #           messages[:error] << 'You do not have the permission to make the following update'
  #           raise_unauthorized_exception
  #         end
  #       end
  #     end
  #     team = User::Team::Index.(user, view: 'admin')
  #     self.updating_user = team.with_id(user_id).first rescue nil
  #   end
  # end

  def init
    user_id = (params[:id] or params[:user_id])
    self.policy = user.company.policies.find_by(id: params[:policy_id])
    self.updating_user = policy.users.find_by(id: user_id)
    self.updating_mapping = updating_user.team_mapping.with_id(params[:mapping_id]).first rescue nil
  end

  def authorize
    unless user.policy_admin?(policy)
      raise_unauthorized_exception
    end
  end

  def validate
    unless self.updating_mapping.present?
      messages[:error] << 'Team mapping not found'
      raise_unauthorized_exception
    end
  end

  def process
    unless self.updating_mapping.destroy
      messages[:error] = self.updating_mapping.errors.full_messages
    end
  end

  def post_process
    messages[:success] << 'Mapping destroyed!'
  end

end