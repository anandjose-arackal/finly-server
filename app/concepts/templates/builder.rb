class Templates::Builder

  attr_accessor :record, :template, :api, :params, :parent, :association_name, :root_record, :block

  def self.call(args = {}, &block)
    builder = self.new(args, &block)
    builder.build
  end

  def initialize(args = {}, &block)
    args.each_pair do |attr, value|
      self.send("#{attr}=", value)
    end
    self.block = block
    instance_exec self, &block if block_given?
  end

  def templates
    api.class.templates
  end

  def build
    record ||= find(template)
    record ||= match(template)
    return nil if finder.nil? and matcher.nil? and parent.persisted?

    record ||= Templates::Cloner.(template, self, &clone)

    self.root_record ||= record

    associations.each do |name, config_block|
      association_template = template.send(name)
      if association_template.respond_to?(:each)
        association_template.each do |record_template|
          build_association(template: record_template, parent: record, association_name: name, &config_block[:evaluator])
        end
      else
        build_association(template: association_template, parent: record, association_name: name, &config_block[:evaluator])
      end
    end
    # debugger if record.class.name == Form.name
    record.save if parent.blank? or parent.persisted?

    record
  end

  def find(template)
    return unless finder.present?

    finder.call(self, template)
  end

  def match(template)
    return if parent.nil?
    return if association_name.nil?
    return if matcher.blank?

    matchers = parent.send(association_name)
    if matchers.respond_to?(:each)
      matchers.each do |record|
        return record if matcher.call(template, record)
      end
    else
      return record if matcher.call(template, matchers)
    end

    nil
  end

  # Finder is used for finding matching records from dB
  def finder(&block)
    @finder = block if block_given?
    @finder
  end

  # Matcher is used for running through associations to find a match
  def matcher(&block)
    @matcher = block if block_given?
    @matcher
  end

  def clone(&block)
    @clone = block if block_given?
    @clone
  end

  def associations
    @associations ||= {}
  end

  def association(name, condition: nil, &evaluator)
    associations[name] = {evaluator: evaluator, condition: condition}
  end

  def build_association(template:, parent: nil, association_name: nil, &block)
    Templates::Builder.(
        {params: params, template: template, parent: parent, api: self.api, association_name: association_name, root_record: root_record},
        &block
    )
  end

end