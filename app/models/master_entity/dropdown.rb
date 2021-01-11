class MasterEntity::DropDown < MasterEntity
  register :dropdown
  database_type :string
  filter_type :dropdown
  set :hint, 'Select value'
  operators :eq_any, :not_eq_all, :not_null, :null

  def initialize(attributes = nil)
    super
    self.choices_scope ||= Choices[:list].()
  end
end