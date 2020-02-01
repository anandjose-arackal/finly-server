class Forms::Entity::Types::Amount < Forms::Entity::Base
  register :amount
  hint 'Amount'

  def initialize(section, field_key, parent_path, opts = {}, &block)
    super(section, field_key, parent_path, opts.merge(populate_if_empty: ::Amount)) do
      number :value, decimal: true
      number :currency_id, scope: Forms::Entity::Scope[:enum].scope(Currency, :id, :country_code, :country, :symbol)
    end
  end
end