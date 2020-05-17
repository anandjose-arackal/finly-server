class Forms::Rules::Operator
  attr_accessor :entity_path

  def initialize(entity_path)
    self.entity_path = entity_path
  end

  Forms::Rules::Constants::PREDICATES.each do |predicate|
    define_method predicate do |type: nil, value: nil, formula: nil, entity: nil|
      type ||= :value if value.present?
      type ||= :formula if formula.present?
      type ||= :entity if entity.present?
      type ||= :none
      Forms::Rules::Rule.new({entity: entity_path}, predicate, type: type, value: value, formula: formula, entity: entity)
    end
  end
end