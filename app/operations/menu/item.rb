class Menu::Item

  attr_accessor :key, :id, :path, :icon, :label, :create, :parent

  def initialize(params = {}, &block)
    params.each_pair do |attr, value|
      self.send("#{attr}=", value)
    end

    load_defaults

    instance_eval &block if block_given?
  end

  def items
    @items ||= []
  end

  def item(key, path: nil, icon: nil, label: nil, create: false, &block)
    items << Menu::Item.new(key: key, path: path, icon: icon, label: label, create: create, parent: self, &block)
  end

  def load_defaults
    self.id = parent.present? ? "#{parent&.id}_#{key}" : key
    self.path ||= key
    self.label ||= path.to_s.titleize
    self.create ||= false
    # self.icon ||= "" todo
  end

  def as_json(options={})
    json = {
        id: id,
        path: path,
        icon: icon,
        label: label,
        create: create,
    }
    json[:items] = items.as_json(options) if items.present?
    json
  end

end