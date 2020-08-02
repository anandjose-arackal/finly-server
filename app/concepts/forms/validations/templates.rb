class Forms::Validations::Templates

  def self.[](key)
    validates[key]
  end

  def self.validates(key = NoObject, &block)
    @validates ||= {}
    @validates[key] = block if key != NoObject and block_given?
    @validates
  end

  validates :max_value do |contract:, entity:, **|
    if entity.options['max_value'].present?
      contract.validates entity.entity_key.to_sym, numericality: {less_than_or_equal_to: entity.options['max_value']}
    end
  end

  validates :min_value do |contract:, entity:, **|
    if entity.options['min_value'].present?
      contract.validates entity.entity_key.to_sym, numericality: {greater_than_or_equal_to: entity.options['min_value']}
    end
  end

  validates :minimum do |contract:, entity:, **|
    if entity.options['minimum'].present? and entity.options['minimum'] > 0
      contract.validates entity.entity_key.to_sym, length: {minimum: entity.options['minimum']}
    end
  end

  validates :maximum do |contract:, entity:, **|
    if entity.options['maximum'].present? and entity.options['maximum'] > 0
      contract.validates entity.entity_key.to_sym, length: {maximum: entity.options['maximum']}
    end
  end

  validates :choices do |contract:, entity:, **|

  end

end