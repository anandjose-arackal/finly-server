class Forms::Definitions::Property < Forms::Definitions::Section

  def self.filters(list = NoObject)
    unless list == NoObject
      @allowed_filters = list
    end
    @allowed_filters ||= []
  end

  def self.attributes(hash = NoObject)
    unless hash == NoObject
      @default_attributes = hash
    end
    @default_attributes ||= {}
  end

  def self.options(hash = NoObject)
    unless hash == NoObject
      @default_options = hash
    end
    @default_options ||= {}
  end

  def self.field_type(value = NoObject)
    unless value == NoObject
      @field_type = value
    end
    @field_type
  end

  def self.hint(value = NoObject)
    unless value == NoObject
      @hint = value
    end
    @hint
  end

  def initialize(section, parents, key, params={}, &block)
    self.section = section
    self.parents = parents
    self.parent = self.parents.last
    self.key = key
    attributes = params&.except(:options) || {}
    options = params&.dig(:options) || {}
    attributes[:label] = label_for(key, options)
    super(key, default_attributes.merge(attributes), default_options.merge(options), &block)
  end

  def default_attributes
    self.class.attributes.merge(
        {
            label: nil,
            default_value: nil,
            editable: true,
            hidden: false,
            required: false,
            unique: false,
        }
    )
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

  # def filter_key
  #   prefix = ''
  #   if parents.present?
  #     parents.map {|p| prefix += p.key.to_s}
  #     prefix += '_'
  #   end
  #   "#{prefix}#{key}"
  # end
  #
  # def filter_choices
  #   options[:choices]
  # end
  #
  # def filter_multiple
  #   false
  # end
  #
  # def filter_form
  #   {
  #       attribute: filter_key,
  #       label: self.options[:label],
  #       field_type: field_type,
  #       regex: options[:regex],
  #       choices: filter_choices
  #   }.reject {|_, v| v.nil?}
  # end

  protected

  def label_for(key, options)
    return options[:label]&.to_s if options[:label].present?

    prefix = ''
    if parents.present?
      parents.map {|p| prefix += p.attributes[:label]}
      prefix += ' '
    end
    "#{prefix}#{key.to_s.humanize}"
  end

end