class User::Team::Mappings::Index < User::Team::Mappings::Base

  def pre_authorize
    unless user.present?
      messages[:error] << 'User not found'
    end
  end

  def init
    self.mappings = user.team_mapping.policy(params[:policy_id])
  end

  def process
    self.response = self.mappings
  end

end