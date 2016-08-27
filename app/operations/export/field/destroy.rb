class Export::Field::Destroy < Export::Base

  attr_accessor :destroy_params

  def init
    self.company = user.company
    self.destroy_params = export_params
    self.preference = company.export_preferences.find_by(id: destroy_params[:export_field_id])
  end

  def validate
    unless preference
      errors << "Cannot find field to delete."
    end
  end

  def process
    unless preference.destroy
      errors << preference.errors.full_messages
    end
  end
end