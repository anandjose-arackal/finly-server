class Templates::Synchronizer
  include DynamicAttributes

  instance_attr :setters, default: {}
  instance_attr :associations, default: {}

  attr_accessor :association_name, :exec_context, :matcher, :condition

  def initialize(association_name, exec_context, args, &block)
    self.condition = args[:condition]
    self.association_name = association_name
    self.exec_context = exec_context
    instance_exec exec_context, &block
  end

  def matcher(&block)
    self.matcher = block if block_given?
    @matcher
  end

  def templates
    exec_context[:templates]
  end

  def set(attribute, value)
    setters[attribute] = value
  end

  def association(name, condition: nil, &evaluator)
    associations[name] = {evaluator: evaluator, condition: condition}
  end

  def clone(template)
    attrs = template.attributes.except('id', 'uuid', 'created_at', 'updated_at', 'deleted_at')
    attrs.merge(setters)
  end

  def sync(template, record)
    return if matcher.blank? and exec_context[:parent].persisted?

    association_template = template.send(association_name)
    association_record = record.send(association_name)


    if association_template.respond_to?(:each)
      sync_collection(association_template, association_record)
    else
      if association_record.nil?
        if condition.blank? or condition.call(association_template)
          record = exec_context[:parent].send("build_#{association_name}", clone(association_template))
          sync_record association_template, record
        end
      end
    end
  end

  def sync_collection(temp_records, records)
    temp_records.each do |temp_record|
      next if condition.present? and not condition.call(temp_record)

      # Check if matching record exists
      matching_record = nil
      records.each do |record|
        next unless match?(temp_record, record)

        matching_record = record
      end

      # Clone if no matching record is found
      if matching_record.nil?
        matching_record = records.new(clone(temp_record))
      end

      sync_record(temp_record, matching_record)
    end
  end

  def sync_record(template, record)
    # Evaluate associations of the matching records for cloning
    associations.each do |association_name, args|
      context = exec_context.dup
      context[:parent] = record
      context[:template] = template
      eval = Templates::Synchronizer.new association_name, context, args, &args[:evaluator]
      eval.sync(template, record)
    end

    if (exec_context[:parent].blank? or exec_context[:parent].persisted?) and not record.persisted?
      unless record.save
        raise record.errors.full_messages.join(", ")
      end
    end
  end

  def match?(template, record)
    return false unless matcher.present?

    !!matcher.call(template, record) || false
  end
end