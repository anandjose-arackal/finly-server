class QuickbooksFinlyIntegrationsDepartment
  include QuickbooksFinlyIntegratable

  attr_accessor :name

  def save
    if self.valid?
      # add logic to save the new department into the DB
    end
  end
end