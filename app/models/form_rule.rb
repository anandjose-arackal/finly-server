# == Schema Information
#
# Table name: form_rules
#
#  id                :bigint           not null
#  company_id        :bigint           not null
#  form_id           :string(255)      not null
#  rule_parent_id    :string(255)      not null
#  rule_parent_type  :string(255)      not null
#  entity_path       :string(255)      not null
#  predicate         :string(255)      not null
#  rule_type_id      :integer          not null
#  match_value       :text(65535)
#  match_formula     :string(255)
#  match_entity_path :string(255)
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  uuid              :string(36)       not null, primary key
#

class FormRule < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :rule_parent, polymorphic: true
  belongs_to :rule_type, class_name: "FormRuleType"

  serialize :match_value, JSON

  delegate 'value?', 'entity?', 'formula?', to: :rule_type

  validates :predicate, inclusion: {in: Forms::Rules::Constants::PREDICATES}

  # def nested_hash_value(obj, key)
  #   if obj.respond_to?(:key?) && obj.key?(key)
  #     obj[key]
  #   elsif obj.respond_to?(:each)
  #     r = nil
  #     obj.find { |*a| r = nested_hash_value(a.last, key) }
  #     r
  #   end
  # end

  def match?(data)
    input = fetch_flat_data(data, entity_path)
    input ||= fetch_row_data(data[:row], entity_path) if data[:row].present?
    input ||= fetch_form_data(data[:form], entity_path)
    entity = form.find_entity(entity_path)
    raise "Entity #{entity_path} not found" if entity.nil?
    # return false unless entity.present?

    rule_value = match_value
    # todo Formula
    # todo Entity
    entity.send("match_#{predicate}?", input, rule_value)
  end

  # Navigates through the entire form path to fetch the data
  def fetch_form_data(data, path)
    paths = path.split("/")
    result = data
    while (p = paths.shift)
      return nil if result.nil?
      # Final node
      return result[p] if paths.blank?
      return nil unless result.class <= Hash
      result = result[p]
    end

    nil
  end

  def fetch_flat_data(data, path)
    data[path]
  end

  def fetch_row_data(data, path)
    paths = path.split('/')
    data&.dig(paths.last)
  end

  def as_json(options = {})
    {
        entity_path: entity_path,
        predicate: predicate,
        rule_type: rule_type.name,
        match_value: match_value,
        match_formula: match_formula,
        match_entity_path: match_entity_path
    }
  end
end
