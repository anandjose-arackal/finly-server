# == Schema Information
#
# Table name: purchase_requests
#
#  id                         :bigint           not null, primary key
#  description                :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  location_id                :integer
#  department_id              :integer
#  policy_id                  :integer
#  controlling_level_id       :integer
#  company_id                 :integer
#  purchase_request_status_id :integer
#  note                       :text(65535)
#  creator_id                 :integer
#  submitted_at               :datetime
#  approved_at                :datetime
#  order_number               :string(255)
#  reject_note                :text(65535)
#  cost_center_id             :integer
#  total_amount_id            :integer
#  cost_allocation_items      :boolean          not null
#  deleted_at                 :datetime
#  base_currency_id           :integer
#  reporting_currency_id      :integer
#

class PurchaseRequest < ApplicationRecord
  attr_accessor :skip_callback
  include Transitionable, CustomFieldFilterSupport, ControllingUser, GetCurrency
  include Sequenced::ActsAsSequenced
  # include SearchIndex::Concerns::Document
  include Searchkick::Api
  include LiquidDroppable
  include Exposures::Model::Exposable
  include FormsHelper
  

  acts_as_sequenced column: :order_number, purpose: :purchase_request, editable: false, prefix: 'PR'

  alias_attribute :created_by_id, :creator_id

  default_scope { order(order_number: :desc, created_at: :desc) }

  # belongs_to :purchase_request_status, optional: true
  belongs_to :status, optional: true, class_name: 'PurchaseRequestStatus', foreign_key: :purchase_request_status_id
  belongs_to :purchase_request_status, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :policy, optional: true
  belongs_to :company, optional: true
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :created_by, optional: true, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id
  belongs_to :purchase_order, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :total_amount, optional: true, class_name: "Amount", dependent: :destroy
  has_many :attachments, as: :resource, dependent: :destroy
  belongs_to :base_currency, optional: true, class_name: 'Currency'
  belongs_to :reporting_currency, optional: true, class_name: 'Currency'

  # has_many :line_items, class_name: "PurchaseRequestItem", dependent: :destroy
  has_many :purchase_request_items, dependent: :destroy
  has_many :items, class_name: "PurchaseRequestItem", dependent: :destroy
  has_many :line_items, class_name: "PurchaseRequestItem", dependent: :destroy
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable
  has_many :form_custom_fields, class_name: 'FormCustomField', as: :document, dependent: :destroy
  has_many :email_approvals, as: :documentable

  validates :description, :location, :policy, presence: true

  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, :closed?, :order_initiated?, :cancelled?, :partially_closed?, to: :status, allow_nil: true

  before_validation :add_company

  accepts_nested_attributes_for :purchase_request_items, :custom_fields, :attachments, allow_destroy: true

  before_create :set_creator
  before_create :set_currency
  after_save :budget_trail_entry, if: :budget_enabled?
  after_save :sync_amounts, unless: :skip_callback
  after_save :set_currency_for_amount, unless: :skip_callback
  after_destroy :budget_trail_destroy

  has_paper_trail(
      meta: {
          parent_document_type: "Purchase Request",
          document_number: Proc.new { |document| document.order_number }
      }
  )


  scope :search_by_email, -> (email) {
    user = RequestStore.store[:current_user]
    if user.present?
      # where creator_id: User.find_by(email: email)&.id
      where creator_id: user.company.users.find_by_email(email)&.id
    end
  }

  scope :not_draft, -> { where.not purchase_request_status_id: PurchaseRequestStatus.id_for(:draft) }

  scope :deleteable, -> { where purchase_request_status_id: [PurchaseRequestStatus.id_for(:draft), PurchaseRequestStatus.id_for(:retracted), PurchaseRequestStatus.id_for(:rejected)] }

  scope :with_ids, -> (ids) { where id: ids }

  scope :with_company_id, -> (company_id) { where company_id: company_id }
  scope :filter_by_status_id, -> (status_id) {
    if status_id == 'awaiting_approval'
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        ids = self.awaiting_action_items(user_id)&.pluck(:id)
        with_id(ids)
      end
    else
      where purchase_request_status_id: status_id
    end
  }

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

  scope :with_status_ids, -> (status_ids) {
    case status_ids
    when PurchaseRequestStatus::GROUP_OPEN
      where purchase_request_status_id: PurchaseRequestStatus.ids_for(:draft, :retracted)
    when PurchaseRequestStatus::GROUP_AWAITING_APPROVAL
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        where("#{table_name}.purchase_request_status_id": PurchaseRequestStatus.id_for(:awaiting_approval)).awaiting_action_items(user_id)
      end
    when PurchaseRequestStatus::GROUP_APPROVED
      where purchase_request_status_id: PurchaseRequestStatus.ids_for(:approved, :auto_approved, :po_created, :partially_closed, :order_initiated)
    when PurchaseRequestStatus::GROUP_APPROVED_ITEM
      joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved)])
    else
      where purchase_request_status_id: status_ids
    end
  }

  scope :filter_status_id, -> (status_ids) {
    with_status_ids(status_ids)
  }

  scope :filter_user_id, -> (ids) {
    where creator_id: ids
  }

  scope :filter_policy_id, -> (policy_id) { where policy_id: policy_id }

  scope :filter_location_id, -> (location_id) { where location_id: location_id }

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

  # Sorting
  scope :sort_order_number, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      reorder("purchase_requests.order_number #{type}")
    end
  }

  scope :sort_description, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      reorder("purchase_requests.description #{type}")
    end
  }

  scope :sort_date, -> (type) {
    type = type&.strip&.upcase
    if type && ['ASC', 'DESC'].include?(type)
      # nosqli - The incoming var is checked to be ASC or DESC and then only substituted, not other value other than "ASC" or "DESC" possible
      reorder("purchase_requests.created_at #{type}")
    end
  }

  scope :filter_pr_creator_id, -> (creator_id) {
    where(creator_id: creator_id)
  }

  scope :filter_pr_approver_id, -> (approver_id) {
    if approver_id.present?
      ids = self.awaiting_action_items(approver_id)&.pluck(:id)
      with_ids(ids)
    end
  }

  scope :role_based_filter, -> (boolean) {
    if boolean
      user = RequestStore.store[:current_user]
      if user.present?
        role_based_policy_ids = user.company.policies.joins(:policy_user_roles).with_application('vp').where('policy_user_roles.user_role_id IN (?) AND policy_user_roles.user_id = ?', [UserRole.id_for(:purchase_order_initiator), UserRole.id_for(:inventory_manager)], user.id).pluck(:id).uniq rescue []
        pr_ids = user.company.purchase_requests.where(policy_id: role_based_policy_ids).joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)])
        with_ids(pr_ids)
      end
    end
  }

  scope :includes_for_contract, -> {
    includes(:form_custom_fields, :items)
  }

  ransack_scopes :with_status_ids

  # scope :sort_amount, -> (type){
  #   type = type&.strip&.upcase
  #   if type && ['ASC', 'DESC'].include?(type)
  #     includes(:total_amount).reorder("amounts.value #{type}")
  #   end
  # }

  def add_company
    self.company_id = self.creator.company_id if self.company_id.blank?
  end

  def entity_date
    created_at.to_date
  end

  def entity_created_at
    created_at.to_date
  end

  def entity_submitted_at
    submitted_at&.to_date || created_at&.to_date
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
        creator_attributes: {creator_id: self.creator_id, creator_name: self.creator&.name, created_at: self.created_at.to_date},
        total_cost: self&.total_amount&.value,
        controlling_user: self.get_reviewers&.first&.name,
        rejection_note: self.reject_note,
        department: self.department&.name,
        cost_center: self.cost_center&.name,
        cost_allocation_items: cost_allocation_items,
        base_currency: get_base_currency,
        reporting_currency: get_reporting_currency
    }
  end

  def controlling_user
    self.get_reviewers&.first
  end

  def self.awaiting_records user
    user_id = user.id
    if user_id.present?
      where("#{table_name}.purchase_request_status_id": PurchaseRequestStatus.id_for(:awaiting_approval)).awaiting_action_items(user_id)
    end
  end

  def calculate_total_amount
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

  def reject_purchase_request_items(options = {}, user)
    rejected_item_ids = options[:rejected_purchase_request_items]
    # Filter rejected ids
    filtered_rejected_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id IN (?)", rejected_item_ids).pluck('purchase_request_items.id')
    # rejected_items = PurchaseRequestItem.with_ids(filtered_rejected_item_ids).update_all(rejected: true, status_id: PurchaseRequestItemStatus.id_for(:rejected)) unless filtered_rejected_item_ids.blank?
    PurchaseRequestItem.with_ids(filtered_rejected_item_ids).each do |item|
      item.rejected = true
      item.status_id = PurchaseRequestItemStatus.id_for(:rejected)
      unless item.save && PurchaseRequest.create_status_change_trail(item, user, action_id = TrailAction.id_for(:reject))
        return false
      end
    end unless filtered_rejected_item_ids.blank?
    true
  end

  def approve_purchase_request_items(options = {}, user)
    approved_item_ids = options[:approved_purchase_request_items]
    # Filter rejected ids
    filtered_approved_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id IN (?)", approved_item_ids).pluck('purchase_request_items.id')

    PurchaseRequestItem.with_ids(filtered_approved_item_ids).each do |item|
      item.rejected = false
      item.status_id = PurchaseRequestItemStatus.id_for(self.reload&.status&.name&.to_sym)
      pr_status = self&.status&.name
      if pr_status == 'approved'
        trail_status = 'approve'
      elsif pr_status == 'auto_approved'
        trail_status = 'auto_approve'
      end
      unless item.save && PurchaseRequest.create_status_change_trail(item, user, action_id = TrailAction.id_for(trail_status))
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
    self.status_ids(:awaiting_approval, :approved, :auto_approved, :retracted, :rejected, :closed, :order_initiated, :cancelled, :po_created, :partially_closed)
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if (UserRole.id_for(:purchase_request_initiator) == role_id.to_i)
          statuses += [:draft, :retracted, :awaiting_approval, :approved, :rejected, :auto_approved, :issued_from_inventory]
        elsif (UserRole.id_for(:purchase_request_reviewer) == role_id.to_i)
          statuses += [:awaiting_approval, :approved, :auto_approved, :issued_from_inventory, :po_created]
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

  def can_take_control?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    return false if user.blank?
    return false if self.action_users(:approve).include?(user)
    awaiting_approval? && user.vendor_payment_admin? && (self.document_level_reviewer_mappings&.find_by(level_id: self.level&.id)&.taken_control_by_id != user.id rescue false) # todo, add dlrm logic
  end

  def can_delete?
    (self.draft? || self.retracted? || self.rejected?) rescue false
  end

  def update_total_amount
    updated_amount = calculate_total_amount
    if updated_amount.present?
      if self.total_amount.present?
        self.total_amount.update_attributes(value: updated_amount)
      else
        if self.create_total_amount(currency_id: get_base_currency.id, value: updated_amount)
          self.save
        end
      end
    end
  end

  # Used for tracking completion %
  def review_pending?
    PurchaseRequestStatus.ids_for(:draft, :retracted, :rejected).include?(purchase_request_status_id)
  end

  def review_completed?
    PurchaseRequestStatus.ids_for(:approved,:auto_approved,:closed,:order_initiated,:cancelled,:po_created,:partially_closed).include?(purchase_request_status_id)
  end

  def review_in_progress?
    PurchaseRequestStatus.ids_for(:awaiting_approval).include?(purchase_request_status_id)
  end
  
  def set_currency
    self.reporting_currency_id = self.company.reporting_currency.id if self.reporting_currency_id.blank? 
    self.base_currency_id = self.company.reporting_currency.id if self.base_currency_id.blank? 
  end

  def set_creator
    self.creator_id = RequestStore.store[:current_user]&.id if self.creator_id.blank?
  end

  def form_klass
    Forms::Router.klass(:purchase_requests)&.name
  end

  def retrieve_value(entity) 
    return 'Processing' if entity.entity_key == 'purchase_request_status_id' && self.purchase_request_status_id == PurchaseRequestStatus.id_for(:awaiting_approval) && !can_approve?
 
    send("#{entity.entity_key.gsub('_id', '')}")&.name rescue send(entity.entity_key)
  end

  def forms_enabled
    if RequestStoreUtil.current_user.blank?
      feature_flag_enabled = true
    else
      feature_flag_enabled = PurchaseRequestToggle.new(RequestStoreUtil.current_user).enabled?
    end
    feature_flag_enabled && self.form_migrated
  end

  def purchase_request_budgets
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self, current_user: User.first})
    budgets = op["result"][:budgets]
    budgets
  end

  def purchase_request_budget_contributions_before_update
    if self.company.enforce_budget_configuration.enforce_purchase_request_budget?
      op = BudgetManager::BudgetLimitValidator::PurchaseRequest.({ purchase_request: self, ignore_unbudgetables: true, current_user: self.created_by })
      op['result'][:budget_contributions] rescue {}
    end
    {}
  end

  def purchase_request_budget_limit_validation
    if self.company.enforce_budget_configuration.enforce_purchase_request_budget?
      return BudgetManager::BudgetLimitValidator::PurchaseRequest.({ purchase_request: self, previous_budget_contributions: self.purchase_request_budget_contributions_before_update, current_user: self.company.users.first })
    end
  end

  # def purchase_request_status_id
  #   !can_approve? && awaiting_approval? ? PurchaseRequestStatus.id_for(:processing) : super
  # end

  def controlling_user
    self.get_reviewers&.first
  end

  private

  def sync_amounts
    if forms_enabled
      sync_to_old_structure
    end
  end

  def sync_to_old_structure
    self.skip_callback = true

    amounts_attributes_map.each do |key, value|
      amount_value = self.send(key)
      amount_attr = self.send("#{value}_id")
      if amount_attr.present?
        Amount.find_by(id: amount_attr).update(value: amount_value, currency_id: base_currency_id)
      else
        amount_id = Amount.create(value: amount_value, currency_id: base_currency_id).id
        self.send("#{value}_id=", amount_id)
      end
    end
    self.save
  end

  def amounts_attributes_map
    {  
      pr_gross_amount: 'total_amount'
    }
  end

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

  def cost_allocation_items?
    self.cost_allocation_items
  end

  def budget_trail_entry
    if self.rejected? || self.cancelled?
      # this will delete the trails of all the items within this particular purchase order
      self.items.each do |item|
        BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor.new.destroy_trail(item)
      end
    else
      self.items.each do |item|
        BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor.new.save_trail(item)
      end
    end
  end

  def budget_trail_destroy
    self.items.each do |item|
      BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor.new.destroy_trail(item)
    end
  end

  def set_currency_for_amount
    amount_attr = [:total_amount]
    amount_attr.each do |amount_attribute|
      amount_attr_id = self.send("#{amount_attribute}_id")
      if amount_attr_id.present?
        Amount.find_by(id: amount_attr_id).update(currency_id: get_base_currency.id)
      end
    end
    self.skip_callback = true
    self.save
  end

  def budget_enabled?
    RequestStore.store[:current_company]&.feature_subscription&.budgeting_system || false
  end

end
