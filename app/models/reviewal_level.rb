# == Schema Information
#
# Table name: reviewal_levels
#
#  id                     :integer          not null, primary key
#  level_number           :integer
#  policy_id              :integer
#  associated_entity_type :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  is_deleted             :boolean          default(FALSE), not null
#  deleted_at             :datetime
#

class ReviewalLevel < ApplicationRecord
  include SoftDeletable

  after_destroy :reassign_level_numbers

  belongs_to :policy, optional: true
  has_many :level_reviewer_mappings, foreign_key: :level_id, dependent: :destroy
  has_many :reviewers, class_name: 'User', through: :level_reviewer_mappings

  has_many :level_user_reviewer_mappings, foreign_key: :level_id, dependent: :destroy
  alias_method :lurms, :level_user_reviewer_mappings

  validates :policy_id, presence: true
  validates :level_number, presence: true
  validates :associated_entity_type, presence: true

  default_scope { unscope(:where) }

  scope :with_id, -> (ids) { where id: ids }
  scope :with_entity_type, -> (type) { where associated_entity_type: type }
  scope :with_level_number, -> (number) { where level_number: number }
  scope :with_policy_ids, -> (ids) {where policy_id: ids}
  scope :with_policy_id, -> (ids) {where policy_id: ids}
  scope :with_associated_entity_type, -> (associated_entity_type) { where associated_entity_type: associated_entity_type}

  # alias_method :filter_associated_entity_type, :with_entity_type
  # alias_method :filter_policy, :with_policy_ids

  # Since you can alias scopes as they are class methods, you have use the below method
  singleton_class.send :alias_method, :filter_associated_entity_type, :with_entity_type
  singleton_class.send :alias_method, :filter_policy, :with_policy_ids
  singleton_class.send :alias_method, :filter_policy_id, :with_policy_ids
  singleton_class.send :alias_method, :filter_policy_ids, :with_policy_ids
  singleton_class.send :alias_method, :with_ids, :with_id

  def get_level(type)
    # Provide :next / :prev to get the respective levels
    if type == 'next' || type == :next
      level_number = self.level_number + 1
    elsif ['previous', :previous, 'prev', :prev].include?(type)
      level_number = self.level_number - 1
    else
      return nil
    end

    ReviewalLevel.exclude_deleted.where({
                                            level_number: level_number,
                                            policy_id: self.policy_id,
                                            associated_entity_type: self.associated_entity_type
                                        }).first
  end

  def set_reviewer_role_in_policy(reviewer)
    associated_entity_type = self.associated_entity_type
    case associated_entity_type
    when 'PurchaseOrderProvider', :PurchaseOrderProvider
      if reviewer.policy_user_roles.with_policy_id(self.policy_id).with_role_id(UserRole.id_for(:purchase_order_reviewer)).blank?
        reviewer.policy_user_roles.create(user_role_id: UserRole.id_for(:purchase_order_reviewer), policy_id: self.policy_id)
      end
    when 'InvoiceProvider', :InvoiceProvider
      if reviewer.policy_user_roles.with_policy_id(self.policy_id).with_role_id(UserRole.id_for(:invoice_reviewer)).blank?
        reviewer.policy_user_roles.create(user_role_id: UserRole.id_for(:invoice_reviewer), policy_id: self.policy_id)
      end
    when 'BankPaymentRequestProvider', :BankPaymentRequestProvider
      if reviewer.policy_user_roles.with_policy_id(self.policy_id).with_role_id(UserRole.id_for(:bank_payment_request_reviewer)).blank?
        reviewer.policy_user_roles.create(user_role_id: UserRole.id_for(:bank_payment_request_reviewer), policy_id: self.policy_id)
      end
    end
  end

  private

  def reassign_level_numbers
    levels = self.class.exclude_deleted.with_policy_ids(self.policy_id).with_associated_entity_type(self.associated_entity_type).where('level_number > ?', self.level_number)
    levels.each do |level|
      level.update(level_number: level.level_number - 1)
    end
  end
end
