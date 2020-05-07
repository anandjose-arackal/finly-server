class Forms::API::Entity::Types::Amount < Forms::API::Entity::Base
  register :amount
  hint 'Amount'

  operators :eq_any, :gteq, :lteq, :blank

  def initialize(section, entity_key, parent_path, opts = {}, &block)
    super(section, entity_key, parent_path, opts.merge(populate_if_empty: ::Amount)) do
      number :value, decimal: true
      number :currency_id, choices_scope: Choices[:enum].(Currency, name: :display_text)
    end
  end
end