class Forms::API::Rule
  include DynamicAttributes

  attr_accessor :entity_path, :predicate, :match_type_id, :match_values, :match_formula, :match_entity_path

  def initialize(params)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
  end

  module Forms::API::Rule::DSL
    extend ActiveSupport::Concern

    def rules
      @rules ||= []
    end

    def rule(entity_path, predicate, value: nil, formula: nil, match_entity_path: nil)
      value = [value] if  value.present? and not value.respond_to?(:each)

      match_type_id = nil
      # match_type_id = FormRuleType.id_for(:value) if value.present?
      # match_type_id = FormRuleType.id_for(:formula) if formula.present?
      # match_type_id = FormRuleType.id_for(:entity) if match_entity_path.present?

      rules << Forms::API::Rule.new(
          entity_path: entity_path,
          predicate: predicate,
          match_type_id: match_type_id,
          match_values: value,
          match_formula: formula,
          match_entity_path: match_entity_path
      )
    end

  end

end