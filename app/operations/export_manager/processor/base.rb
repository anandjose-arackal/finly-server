class ExportManager::Processor::Base
  attr_accessor :master_class, :user, :params, :file_url

  def initialize(user, params, master_class)
    self.user = user
    self.params = params
    self.master_class = master_class
  end

  def run
    # To be implemented by inheriting processors
  end

end