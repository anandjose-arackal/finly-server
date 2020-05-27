class Rules::Operator
  attr_accessor :entity_path

  def initialize(entity_path)
    self.entity_path = entity_path
  end

  Rules::Constants::PREDICATES.each do |predicate|
    define_method predicate do |type: nil, value: nil, formula: nil, entity: nil|
      if Rules::Constants::NON_VALUE_PREDICATES.include?(predicate)
        value = 1
        formula = nil
        entity = nil
      end
      type ||= :value if value.present?
      type ||= :formula if formula.present?
      type ||= :entity if entity.present?
      type ||= :none
      Rules::Rule.new({entity: entity_path}, predicate, type: type, value: value, formula: formula, entity: entity)
    end
  end
end