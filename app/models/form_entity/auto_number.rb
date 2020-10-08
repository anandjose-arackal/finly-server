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
#  system_field                 :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_choices_be_changed       :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  data_provider                :text(65535)
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
#  compute_enabled              :boolean
#  compute_type_id              :integer
#  compute_lookup_entity_id     :string(255)
#  compute_formula              :text(65535)
#  filters                      :text(65535)
#  config_path                  :string(255)
#

class FormEntity::AutoNumber < FormEntity
  register :auto_number
  set :hint, 'Select option'

  config :sequence

  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present

  schema_validation do
    required(:config) do
      hash do
        required(:sequence) do
          hash do
            required(:prefix).filled
            required(:start_at).filled
          end
        end
      end
    end
  end

  contract_eval "Set sequence" do |contract:, entity:, **|
    contract.after_save do
      if model.send(entity.entity_key).blank?
        prefix = entity.config['prefix']
        # min_length = entity.options['min_length'] || MasterEntity::Sequence::MIN_LENGTH_DEFAULT
        prefix = LiquidHelper.interpolate(prefix, {'record' => model})
        sequence = REDIS.incr("FormEntity::AutoNumber##{entity.id}##{prefix}")
        sequence = sequence.to_s.rjust(min_length, "0")
        model.send("#{entity.entity_key}=", "#{prefix}#{sequence}")
        model.save
      end
    end
  end

  def self.option_validation
    Proc.new do
      validation :options_config do
        params do
          required(:config) do
            hash do
              required(:sequence) do
                hash do
                  required(:prefix).filled
                  required(:start_at).filled
                end
              end
            end
          end
        end
        rule(:config) do
          sequence = value[:sequence]
          prefix = sequence&.dig(:prefix)
          start_at = sequence&.dig(:start_at)
          key.failure("prefix must be present") if prefix.blank?
          key.failure("start_at must be present") if start_at.blank?
        end
      end
    end
  end
end
