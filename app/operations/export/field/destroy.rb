class Export::Field::Destroy < Export::Base

  attr_accessor :destroy_params

  def init
    self.company = user.company
    id = params[:id] or params[:export_field_id]
    self.preference = company.export_preferences.find_by(id: id)
  end

  def authorize
    unless preference
      messages[:error] << "Cannot find field to delete."
    end
  end

  def process
    unless preference.destroy
      messages[:error] << preference.errors.full_messages
    end
  end

  def post_process
    messages[:success] << "Export Field destroyed."
  end

  def success
    Export::Base::FieldPresenter.new(user, {result: true}, messages)
  end

end