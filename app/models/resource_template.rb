# == Schema Information
#
# Table name: resource_templates
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  resource_type :string(255)      not null
#  user_id       :integer          not null
#  last_used_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ResourceTemplate < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true
  validates :resource_type, presence: true

  TEMPLATABLES = {}

  has_many :purchase_orders
  has_many :invoices

  scope :with_resource_type, ->(resource_type) {where resource_type: resource_type}
  scope :filter_resource_type, ->(resource_type) {with_resource_type(resource_type)}

  validate :valid_type

  def self.register(klass)
    key = klass.table_name&.to_sym
    has_many key
    scope key, -> {with_resource_type(key)}
    accepts_nested_attributes_for key
    TEMPLATABLES[klass.table_name] = klass
  end

  def resource
    self.send(self.resource_type)&.first
  end

  protected

  def valid_type
    unless TEMPLATABLES.keys.include?(self.resource_type)
      errors.add :template, 'type is not valid'
    end
  end

  def valid_resource
    if self.resource.blank?
      errors.add :error, 'creating template'
    end
  end

end
