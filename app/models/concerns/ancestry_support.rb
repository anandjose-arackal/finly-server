module AncestrySupport
  extend ActiveSupport::Concern

  included do
    scope :leaves, lambda { joins("LEFT JOIN #{table_name} AS c ON c.#{ancestry_column} = CAST(#{table_name}.id AS char(50)) OR c.#{ancestry_column} = concat(#{table_name}.#{ancestry_column}, '/', #{table_name}.id)").group("#{table_name}.id").having('COUNT(c.id) = 0') }
  end

  def full_name
    self.parent.blank? ? self.name : "#{self.ancestors&.pluck(:name)&.join(' / ')} / #{self.name}"
  end

  def json_tree(options={})
    json = as_json(options)
    json[:children] = children&.map(&:json_tree)
    json
  end

end