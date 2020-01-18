class Masters::Departments::AutoComplete < AutoComplete::API

  schema do
    params do

    end
  end

  handle :departments
  resolver Masters::Departments::Resolver
  render_record [:id, :name]

end