class Forms::Definitions::Property < Forms::Definitions::Section

  include Forms::Definitions::Types::AttributeHelpers::Choices
  include Forms::Definitions::Types::AttributeHelpers::DataUrl
  include Forms::Definitions::Types::AttributeHelpers::Regex

  def attribute_helpers
    [
        Forms::Definitions::Types::AttributeHelpers::Choices,
        Forms::Definitions::Types::AttributeHelpers::DataUrl,
        Forms::Definitions::Types::AttributeHelpers::Regex,
    ]
  end

  def self.filters(list = NoObject)
    @allowed_filters = list unless list == NoObject
    @allowed_filters ||= []
  end

  def self.attributes(hash = NoObject)
    @default_attributes = hash unless hash == NoObject
    @default_attributes ||= {}
  end

  def self.options(hash = NoObject)
    @default_options = hash unless hash == NoObject
    @default_options ||= {}
  end

  def self.field_type(value = NoObject)
    @field_type = value unless value == NoObject
    @field_type
  end

  def self.hint(value = NoObject)
    @hint = value unless value == NoObject
    @hint
  end

  def initialize(section, parents, key, params = {}, &block)
    self.section = section
    self.parents = parents
    self.parent = self.parents.last
    self.key = key
    load_params(params)
    super(key, attributes, options, &block)
  end

  def load_params(params)
    self.options = default_attributes.merge(params&.dig(:options) || {})
    load_attributes params
  end

  def load_attributes(params)
    self.attributes = default_attributes.merge(params&.except(:options) || {})
    self.attributes[:label] = label
    self.attribute_helpers.each do |attribute_helper|
      attribute_helper.load_attributes self
    end
  end

  def default_attributes
    attr = {
        label: nil,
        default_value: nil,
        editable: true,
        hidden: false,
        required: false,
        unique: false,
        system_field: true
    }
    attr.merge(self.class.attributes)
  end

  def default_options
    self.class.options.merge(
        {
            can_editable_be_changed: true,
            can_required_be_changed: true,
            can_uniqueness_be_changed: true,
            can_label_be_renamed: true,
            can_not_be_hidden: false,
            can_be_filtered: true,
            show_in_bulk_import: false,

        }
    )
  end

  def filters
    self.class.filters + %i(
      eq
      not_eq
      cont_any
      not_cont_any
      in
      not_in
      blank
      present
    )
  end

  def contract_type
    :property
  end

  def contract_options
    options
  end

  def association?
    block.present?
  end

  def parents_association
    @parents_association ||= self.parents.dup.push(self)
  end

  def field_type
    self.class.field_type
  end

  def hint
    nil
  end

  def filter_key
    prefix = ''
    if parents.present?
      parents.map {|p| prefix += p.key.to_s}
      prefix += '_'
    end
    "#{prefix}#{key}"
  end

  def filter_choices
    return attributes[:choices] if attributes[:choices].present?
    if attributes[:enum].present?
      model_s = attributes[:enum]&.first
      model = Object.const_get(model_s)
      return nil if model.blank?

      method = attributes[:enum]&.second
      values = model.send(method)
      values.each do |name, value|

      end
    end
  end

  def filter_multiple
    false
  end

  def filter_form
    {
        field_key: filter_key,
        field_type: field_type,
        label: self.label,
        regex: options[:regex],
        choices: filter_choices,
        data_url: data_url
    }.reject {|_, v| v.nil?}
  end

  protected

  def label#(key, attributes)
    return attributes[:label]&.to_s if attributes[:label].present?

    prefix = ''
    if parents.present?
      parents.map {|p| prefix += p.label}
      prefix += ' '
    end
    "#{prefix}#{key.to_s.humanize}"
  end

end