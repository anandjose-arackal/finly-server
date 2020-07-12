class Resolver::Resolve < Transactions::API
  include DynamicAttributes

  schema do
    params do
      required(:route).filled
    end
  end

  MAX_PER_PAGE = 100

  step :assign_defaults
  step Resolver::Transactions::Load(paginate: true)

  def assign_defaults(context, params:, **)
    params[:per_page] ||= MAX_PER_PAGE
    params[:per_page] = [params[:per_page], MAX_PER_PAGE].min
  end

end