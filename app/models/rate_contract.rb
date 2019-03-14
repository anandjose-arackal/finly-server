class RateContract < ApplicationRecord

  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :item, optional: true, class_name: 'Item'
  belongs_to :renewal_alert_period, class_name: 'Period', foreign_key: :renewal_alert_period_id
  belongs_to :company, optional: true
  has_many :rate_contract_line_items, dependent: :destroy
  has_many :artifacts, as: :resource, dependent: :destroy

  before_save :add_company

  validates :renewal_alert_period, :renewal_alert_number, :vendor, presence: true

  accepts_nested_attributes_for :rate_contract_line_items, allow_destroy: true
  accepts_nested_attributes_for :artifacts, allow_destroy: true

  scope :filter_rate_contract_id, -> (contract_id) {
    where id: contract_id
  }
  scope :filter_vendor_id, -> (vendor_id) {
    where vendor_id: vendor_id
  }

  scope :filter_rate_contract_name, -> (contract_name) {
    where name: contract_name
  }

  def as_json
    {
      id: id, 
      name: name, 
      vendor_id: vendor_id,
      vendor_name: vendor&.name,
      renewal_alert_number: renewal_alert_number,
      renewal_alert_period_id: renewal_alert_period_id,
      creator_id: creator_id,
      renewable: renewable,
      note: note,
      default_location_name: (rate_contract_line_items.where.not(location_id: nil).first.location.name rescue nil),
      locations_count: (rate_contract_line_items.pluck(:location_id).count rescue 0),
    }
  end

  def validate_if_owner?(user)
    self.creator_id == user.id
  end

  def validate_if_manager?(user)
    user.is_item_master_manager?
  end

  def validate_if_admin?(user)
    user.admin?
  end

  def add_company
    self.company_id = user.company_id
  end

end
