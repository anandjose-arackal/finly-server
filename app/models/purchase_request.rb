# == Schema Information
#
# Table name: purchase_requests
#
#  id                         :bigint(8)        not null, primary key
#  description                :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  purchase_request_status_id :integer
#  note                       :text(65535)
#  creator_id                 :integer
#  submitted_at               :datetime
#  approved_at                :datetime
#  location_id                :integer
#  department_id              :integer
#  policy_id                  :integer
#  controlling_level_id       :integer
#  company_id                 :integer
#  order_number               :string(255)
#

class PurchaseRequest < ApplicationRecord
  include Transitionable
  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :order_number, purpose: :purchase_request, editable: false, prefix: 'PR-'

  # belongs_to :purchase_request_status, optional: true
  belongs_to :status, optional: true, class_name: 'PurchaseRequestStatus', foreign_key: :purchase_request_status_id
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :policy, optional: true
  belongs_to :company, optional: true
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id
  belongs_to :purchase_order, optional: true
  belongs_to :cost_center, optional: true

  has_many :attachments, as: :resource, dependent: :destroy

  # has_many :line_items, class_name: "PurchaseRequestItem", dependent: :destroy
  has_many :purchase_request_items, dependent: :destroy

  validates :description, :location, :department, :policy, presence: true

  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, :closed?, :order_initiated?, :cancelled?, to: :status

  before_create :add_creator, :add_company, :set_initial_status

  accepts_nested_attributes_for :purchase_request_items, :attachments, allow_destroy: true


  scope :filter_by_status_id,  -> (status_id) { where purchase_request_status_id: status_id }
  scope :search_by_email, -> (email) { where creator_id: User.find_by(email: email)&.id }
  scope :not_draft, -> { where.not purchase_request_status_id: PurchaseRequestStatus.id_for(:draft) }

  scope :with_ids, -> (ids) { where id: ids }


  scope :filter_by_location_id, -> (id) {
    user_id = RequestStore.store[:current_user]&.id
    where location_id: PurchaseRequest.process_location_id(id, user_id)
  }

  scope :filter_by_department_id, -> (id) {
    user_id = RequestStore.store[:current_user]&.id
    where department_id: PurchaseRequest.process_department_id(id, user_id)
    # where department_id: id
  }

  scope :filter_by_title, -> (description) {
    where description: description
  }

  scope :filter_by_request_id, -> (code) {
    where order_number: code
  }

  scope :filter_by_date_range, -> (from, to) {
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    where('DATE(created_at) >= ? && DATE(created_at) <= ?', from, to)
  }

  scope :filter_awaiting_approval, -> (boolean) {
    user_id = RequestStore.store[:current_user]&.id

    if user_id.present?
      ids = self.awaiting_action_items(user_id)&.pluck(:id)
      with_ids(ids)
    end
  }

  scope :with_status_ids, -> (status_ids) {where purchase_request_status_id: status_ids}

  scope :filter_status_id, -> (status_ids) {
    with_status_ids(status_ids)
  }

  scope :filter_user_id, -> (ids) {
    where creator_id: ids
  }

  scope :filter_policy_id, -> (policy_id) {where policy_id: policy_id}

  scope :filter_location_id, -> (location_id) {where location_id: location_id}

  scope :filter_department_id, -> (ids) {
    where department_id: ids
  }

  scope :filter_year, -> (year) {
    if year.blank?
      year = Date.today.year
    end
    where('extract(year from created_at) = ?', year)
  }

  scope :filter_month, -> (month) {
    if month.blank?
      month = Date.today.month
    end
    where('extract(month from created_at) = ?', month)
  }

  def add_creator
    self.creator_id = RequestStore.store[:current_user]&.id
  end

  def add_company
    self.company_id = self.creator.company_id
  end

  def set_initial_status
    self.purchase_request_status_id = PurchaseRequestStatus.id_for(:draft)
  end


  def as_json
    {
      id: self.id,
      purchase_request_number: self.order_number,
      description: self.description,
      location_attributes: {id: self.location_id, name: self.location&.name},
      department_attributes: {id: self.department_id, name: self.department&.name},
      policy_attributes: {id: self.policy_id, name: self.policy&.name},
      status_attributes: {status_id: self.purchase_request_status_id, status_name: self.status&.name, display_name: self.status&.name&.humanize},
      creator_attributes: {creator_id: self.creator_id, creator_name: self.creator&.name, created_at: self.created_at.to_date },
      total_cost: calculate_total_amount,
      controlling_user: self.get_reviewers&.first&.name
    }
  end

  def calculate_total_amount
    # amount_ids = self.purchase_request_items&.pluck(:estimated_amount_id)
    # Amount.where(id: amount_ids)&.pluck(:value).sum
    self.purchase_request_items.non_rejected.joins(:estimated_amount).pluck(:value)&.flatten&.compact&.sum rescue nil
  end

  def get_default_provider
    'PurchaseRequestProvider'
  end

  def self.document_owner_attribute
    'creator_id'
  end

  def self.document_status_attribute
    'purchase_request_status_id'
  end

  def self.document_status_class_name
    'PurchaseRequestStatus'
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push PurchaseRequestStatus.id_for(status)
    end
    status_ids&.flatten&.compact
  end

  # For user role as purchase request initiator
  def is_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:purchase_request_initiator), self)
  end

  # For user role as purchase request reviewer
  def is_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:purchase_request_reviewer), self)
  end

  def reject_purchase_request_items(options={}, user)
    rejected_item_ids = options[:rejected_purchase_request_items]
    # Filter rejected ids
    filtered_rejected_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id IN (?)", rejected_item_ids).pluck('purchase_request_items.id')
    # rejected_items = PurchaseRequestItem.with_ids(filtered_rejected_item_ids).update_all(rejected: true, status_id: PurchaseRequestItemStatus.id_for(:rejected)) unless filtered_rejected_item_ids.blank?
    PurchaseRequestItem.with_ids(filtered_rejected_item_ids).each do |item|
      item.rejected = true
      item.status_id = PurchaseRequestItemStatus.id_for(:rejected)
      unless item.save && PurchaseRequest.create_status_change_trail(item, user, action_id=TrailAction.id_for(:reject))
        return false
      end
    end unless filtered_rejected_item_ids.blank?
    true
  end

  def approve_purchase_request_items(options={}, user)
    approved_item_ids = options[:approved_purchase_request_items]
    # Filter rejected ids
    filtered_approved_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id IN (?)", approved_item_ids).pluck('purchase_request_items.id')

    PurchaseRequestItem.with_ids(filtered_approved_item_ids).each do |item|
      item.rejected = false
      item.status_id = PurchaseRequestItemStatus.id_for(self.reload&.status&.name&.to_sym)
      unless item.save && PurchaseRequest.create_status_change_trail(item, user, action_id=TrailAction.id_for(self&.status&.name&.to_sym))
        return false
      end
    end unless filtered_approved_item_ids.blank?
    true
  end

  def self.open_status_ids(user)
    PurchaseRequestStatus.ids_for([:open, :draft])
  end

  def self.role_based_associated_status_ids(user)
    PurchaseRequestStatus.ids_for(self.role_based_statuses(user))
  end

  def self.auditor_associated_status_ids
    self.status_ids(:awaiting_approval, :approved, :auto_approved, :retracted, :rejected, :closed, :order_initiated, :cancelled, :po_created)
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if (UserRole.id_for(:purchase_request_initiator) == role_id.to_i)
          statuses += [:draft, :retracted, :awaiting_approval, :approved, :rejected, :auto_approved, :issued_from_inventory]
        elsif (UserRole.id_for(:purchase_request_reviewer) == role_id.to_i)
          statuses += [:awaiting_approval, :approved, :auto_approved, :issued_from_inventory]
        end
      end
    end
    return statuses.uniq
  end

  def self.roles
    # {'1'=> 'admin', '17'=> 'bank_payment_request_initiator', '18'=> 'bank_payment_request_reviewer', '19'=> 'bank_payment_request_creditor'}
    [:admin, :purchase_request_initiator, :purchase_request_reviewer, :purchase_request_auditor]
  end

  def self.create_status_change_trail(item, user, action_id)
    # Since PR line item does not have policy, trail has PR data
    role_id = item.purchase_request.is_reviewing_user? ? UserRole.id_for(:purchase_request_reviewer) : UserRole.id_for(:admin)
    trail = item.trails.new action_user: user,
                           action_id: action_id,
                           action_user_role_id: role_id,
                           # Current level if previous level is not present
                           action_level_id: item.purchase_request.get_level(:previous).id || item.purchase_request.level.id,
                           modified_level_id: item.purchase_request&.level&.id
    trail.save
  end


  def can_approve?
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    awaiting_approval? && self.get_reviewers.include?(user)
    # if self.action_users(:take_control).include?(user)
    #   awaiting_approval?
    # elsif self.action_users(:approve).include?(user)
    #   awaiting_approval?
    # else
    #   false
    # end
  end

  def can_reject?
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    awaiting_approval? && self.get_reviewers.include?(user)
    # if self.action_users(:take_control).include?(user)
    #   awaiting_approval?
    # elsif self.action_users(:approve).include?(user) # If user can approve, they can also reject
    #   awaiting_approval?
    # else
    #   false
    # end
  end

  def can_take_control?(user=nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    return false if self.action_users(:approve).include?(user)
    awaiting_approval? && user.vendor_payment_admin? && (self.document_level_reviewer_mappings&.find_by(level_id: self.level&.id)&.taken_control_by_id != user.id rescue false)# todo, add dlrm logic
  end

  private


  def self.process_location_id(location_id, user_id)
    user = User.find_by_id user_id
    location = user.company.locations.find_by_id location_id
    if user.present?
      # If location is parent location, then get all of its child locations
      if location.ancestry.blank?
        return location.descendants.pluck(:id)
      end
    end
    return location_id
  end

  def self.process_department_id(department_id, user_id)
    user = User.find_by_id user_id
    department = user.company.departments.find_by_id department_id
    if user.present?
      # If department is parent department, then get all of its child departments
      if department.ancestry.blank?
        return department.descendants.pluck(:id)
      end
    end
    return department_id
  end

end
