class User::Team::Mappings::Index < User::Team::Mappings::Base

  def process
    self.response = self.mappings
  end

end