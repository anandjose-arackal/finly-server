class QuickView::Builders::Tab
  def self.sections
    @sections ||= []
  end

  def self.section(key, config = {}, &block)
    section = QuickView::Builders::Section.new(config.merge(key: key), &block)
    unless section.valid?
      raise "#{self.name}: #{section.errors.full_messages}"
    end
    sections << section
  end

  def self.render(context, exec_context, user, record, exposure, data)
    section_data = []
    sections.each do |section|
      section_data << section.render(context, exec_context, user, record, exposure, data)
    end

    section_data
  end

  class QuickView::Builders::Tab::Config < NonPersistentModel
    attr_accessor :key, :label, :default, :builder

    validates :key, presence: true
    validates :builder, presence: true

    def post_initialize(attributes = {})
      if self.label.blank?
        self.label = self.key.to_s.humanize
      end
    end

    def render(context, exec_context, user, record, exposure, data)
      builder.render(context, exec_context, user, record, exposure, data)
    end

    def as_json(options = {})
      {
        key: key,
        label: label,
        default: default,
      }
    end
  end
end
