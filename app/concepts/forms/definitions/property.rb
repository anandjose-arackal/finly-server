class Forms::Definitions::Property < Forms::Definitions::Section

  attr_accessor :label

  def self.allowed_filters(list = NoObject)
    unless list == NoObject
      @allowed_filters = list
    end
    @allowed_filters ||= []
  end

  def initialize(section, parents, key, options = {}, &block)
    self.section = section
    self.parents = parents
    self.parent = self.parents.last
    self.label = label_for(key, options)
    super(key, options, &block)
  end

  def label_for(key, options)
    return options[:label]&.to_s if options[:label].present?

    prefix = ''
    if parents.present?
      parents.map {|p| prefix += p.label}
      prefix += ' '
    end
    "#{prefix}#{key.to_s.humanize}"
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
    nil
  end

  def placeholder
    nil
  end

  def default_options
    {
        can_editable_be_changed: true,
        can_required_be_changed: true,
        can_uniqueness_be_changed: true,
        can_label_be_renamed: true,
        can_not_be_hidden: false,
    }
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
    options[:choices]
  end

  def filter_multiple
    false
  end

  def filter_form
    {
        attribute: filter_key,
        label: label,
        field_type: field_type,
        regex: options[:regex],
        choices: filter_choices
    }.reject {|_, v| v.nil?}
  end

end