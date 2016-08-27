class User::Team::Mapping::Index < User::Team::Mapping::Base

  def process
    self.response = self.mappings
  end

end