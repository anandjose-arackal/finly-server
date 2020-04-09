class Filters::API < Transactions::API
  include DynamicAttributes
  include Attribute::Builder

  step :build_config

  def build_config(context, current_user:, **)
    context[:filters] = self.class.build(current_user)
  end

end