class User::Team::Mappings::Destroy < User::Team::Mappings::Base
  attr_accessor :mapping

  def pre_validate
    super
    if params[:team_mapping_id].blank?
      errors << 'Team mapping not found'
    end
  end

  def init
    super
    self.mapping = mappings.with_id(id: params[:team_mapping_id]).first rescue nil
  end

  def authorize
    super
    if self.mapping.blank?
      errors << 'Configuration not found'
      raise_unauthorized_exception
    end
  end

  def process
    unless self.mapping.destroy
      errors << self.mapping.errors.full_messages
    end
    self.response = (not has_errors?)
  end

end