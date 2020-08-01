# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  uuid                         :string(36)       not null, primary key
#  company_id                   :integer          not null
#  form_id                      :string(36)       not null
#  form_section_id              :string(36)       not null
#  created_by_user_id           :integer
#  entity_key                   :string(255)      not null
#  label                        :string(255)
#  placeholder                  :string(255)
#  hint                         :string(255)
#  entity_type                  :string(255)
#  default_value                :string(255)
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :integer
#  custom_field                 :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_choices_be_changed       :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  choices_scope                :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  entity_path                  :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#  type                         :string(255)
#  config                       :text(65535)
#  associate_custom_fields      :boolean
#  compute                      :boolean
#  compute_enabled              :boolean
#  compute_type_id              :integer
#  compute_formula              :string(255)
#  compute_lookup_entity_id     :string(255)
#  filters                      :text(65535)
#

class FormEntity::Date < FormEntity
  register :date
  set :hint, "Select date"

  RESTRICTIONS = %w(
    in_the_future
    in_the_past
    not_in_the_future
    not_in_the_past
  ).freeze

  option :restriction

  operators :gteq_days, :lteq_days, :eq_days, :in_days, :eq_any, :gteq, :lteq, :blank

  contract_eval 'Restriction' do |contract:, entity:, **|
    if entity.options['restriction'].present?
      contract.validate do
        value = send(entity.entity_key)
        next unless value.present?

        case entity.options['restriction']
        when 'in_the_future'
          if value <= DateTime.now.end_of_day
            errors.add entity.entity_key, "can only be in the future"
          end
        when 'in_the_past'
          if value >= DateTime.now.end_of_day
            errors.add entity.entity_key, "can only be in the past"
          end
        when 'not_in_the_future'
          if value > DateTime.now.end_of_day
            errors.add entity.entity_key, "cannot be in the future"
          end
        when 'not_in_the_past'
          if value < DateTime.now.end_of_day
            errors.add entity.entity_key, "cannot be in the past"
          end
        else
          # Do nothing
        end
      end
    end
  end

  schema_validation do
    required(:options) do
      hash do
        optional(:restriction).value(included_in?: RESTRICTIONS)
      end
    end
  end

  def self.option_validation
    Proc.new do
      validation :options_config do
        params do
          required(:options) do
            hash do
              optional(:restriction).value(included_in?: RESTRICTIONS)
            end
          end
        end
      end
    end
  end
end
