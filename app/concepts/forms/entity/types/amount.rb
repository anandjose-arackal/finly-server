class Forms::Entity::Types::Amount < Forms::Entity::Base
  register :amount
  hint 'Amount'

  def initialize(section, field_key, opts = {}, &block)
    super(section, field_key, opts) do
      number :value, decimal: true
      number :currency_id, scope: Forms::Entity::Scope::Enum(Currency, :id, :country_code, :country, :symbol)
    end
  end
end