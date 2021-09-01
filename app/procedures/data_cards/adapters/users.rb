# Responsible for creating user data cards
class DataCards::Adapters::Users < DataCards::API

    def init(context, args)
      super(context, args)
      context[:route] = route = args&.dig(:params, :route)
      return on_error(context, :base, "Invalid route") unless route == "users"

      # Find the document
      context[:model] = model =  User.find_by(
        company_id: context[:current_user].company_id,
        id: context[:params][:id]
      )
      return on_error(context, :base, "Record not found") unless model.present?
  
      true
    end
  
    def build(context, model:, builder:, **)
      builder.title = model.name
      builder.type = 'User'
      builder.status = model.status
      builder.add_detail label: "Name", value: model.name
      builder.add_detail label: "Email", value: model.email
      builder.add_detail label: "Department", value: model.department&.name
      builder.add_detail label: "Cost Center", value: model.cost_center&.name
      builder.add_detail label: "Location", value: model.location&.name

      true
    end
  
end