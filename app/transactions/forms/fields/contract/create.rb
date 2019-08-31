class Forms::Fields::Contract::Create < Reform::Form
  include ::ActiveModel::Validations::Callbacks

  # property :uuid
  property :form_id, validates: {presence: true}
  property :parent_id
  property :company_id, validates: {presence: true}
  property :key, validates: {presence: true}
  property :label, validates: {presence: true},
           deserializer: {parse_pipeline: ->(*) {->(input, represented:, **) {
             represented.label = input[:label] || input['label'] || represented.key.to_s.humanize}}}
  property :placeholder
  property :field_type, validates: {presence: true}
  property :position, validates: {presence: true},
           deserializer: {
               parse_pipeline: ->(*) {
                 ->(input, represented:, **) {
                   if [0, nil].include?(represented.position) and input['form_id'].present?
                     represented.position = input['position'] || FormConfiguration.find_by(id: input['form_id']).fields.count + 1
                   end
                 }}}
  property :form_class, validates: {presence: true}
  property :field_class, validates: {presence: true}
  property :section, validates: {presence: true}
  property :required, default: false
  property :custom, default: true
  property :editable, default: true
  property :visible, default: true
  property :link
  property :hint
  property :regex
  property :default_value
  property :allow_clearing_default_value
  collection :choices, populate_if_empty: :populate_choice do
    property :company_id, validates: {presence: true}
    property :position, validates: {presence: true}
    property :active
    property :value, validates: {presence: true}
  end
  property :options

  def generate_uuid
    return self.uuid if self.uuid.present?
    while self.uuid.blank? or FormField.where(uuid: self.uuid).present?
      self.uuid = SecureRandom.uuid
    end
    self.uuid
  end

  def set_label
    return if self.label.present?
    self.label = self.key&.humanize
  end

  def set_custom_value
    self.custom = true
  end

  def populate_choice(options)
    fragment = options[:fragment]
    FormFieldChoice.new(
        {
            company_id: self.company_id,
            value: fragment[:value],
            active: true,
            position: self.choices.count + 1
        }
    )
  end

end