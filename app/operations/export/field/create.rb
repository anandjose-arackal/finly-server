# action to create and destroy an export field.
# params:
# export :
#   export_field_id: id of the export field that needs to be created
#   name: the custom name that is to be given to the select field. If nil, the export field retains the default name
#
class Export::Field::Create < Export::Base

  attr_accessor :create_params

  def init
    self.company = user.company
    self.create_params = export_params
  end

  def validate
    if create_params.blank?
      messages[:error] << "Invalid data."
    end
  end

  def process
    self.preference = company.export_preferences.build(create_params)
    unless preference.save
      messages[:error] = preference.errors.full_messages
    end
  end

  def post_process
    messages[:success] << 'Configuration saved!'
  end

  def success
    Export::Base::FieldPresenter.new(user, {preference: preference}, messages)
  end

end