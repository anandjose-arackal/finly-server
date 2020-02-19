# == Schema Information
#
# Table name: resource_templates
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  resource_type :string(255)      not null
#  user_id       :integer
#  last_used_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  uuid          :string(36)
#  deleted_at    :datetime
#

class ResourceTemplate < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :resource_type, presence: true

  after_create :update_user_id

  TEMPLATABLES = {}

  has_many :purchase_orders
  has_many :invoices
  has_many :beneficiary_payments

  scope :with_resource_type, ->(resource_type) {where resource_type: resource_type}
  scope :filter_resource_type, ->(resource_type) {with_resource_type(resource_type)}

  validate :valid_type

  def self.register(klass)
    key = klass.table_name&.to_sym
    has_many key
    scope key, -> {with_resource_type(key)}
    accepts_nested_attributes_for key
    TEMPLATABLES[klass.table_name] = klass
    # For models with relation to themselves 'Self Joins'
    # association_reflections =  klass.reflect_on_all_associations(:has_many).map{|c| [c.plural_name, c.class_name]}.to_h
    # TEMPLATABLES.merge!(association_reflections)
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

  private

  def update_user_id
    if self.user_id.blank?
      self.update(user: RequestStore[:current_user])
    end
  end

end
