class MasterEntity::DropDown < MasterEntity
  register :dropdown
  set :hint, 'Select value'
  operators :eq_any, :not_eq_all, :not_null, :null
end