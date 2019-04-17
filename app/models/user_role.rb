# == Schema Information
#
# Table name: user_roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserRole < ApplicationRecord
  has_many :users, through: :user_role_mappings

  scope :admin, -> { where(id: UserRole.id_for(:admin)) }
  scope :finance_manager, -> { where(id: UserRole.id_for(:finance_manager)) }
  scope :manager, -> { where(id: UserRole.id_for(:manager)) }
  scope :employee, -> { where(id: UserRole.id_for(:employee)) }
  scope :auditor, -> { where(id: UserRole.id_for(:auditor)) }
  scope :travel_manager, -> { where(id: UserRole.id_for(:travel_manager)) }

  VALUES = {
      admin: 1,
      finance_manager: 2,
      # creditor: 2,
      manager: 3,
      reviewer: 3,
      employee: 4,
      initiator: 4,
      personal: 4,
      auditor: 5,
      travel_manager: 6,
      purchaser: 7,
      receiver: 8,
      creditor: 9,
      purchase_request_initiator: 10,
      purchase_request_reviewer: 11,
      purchase_order_initiator: 12,
      purchase_order_reviewer: 13,
      goods_receiver: 14,
      invoice_initiator: 15,
      invoice_reviewer: 16,
      bank_payment_request_initiator: 17,
      bank_payment_request_reviewer: 18,
      bank_payment_request_creditor: 19,
      item_master_manager: 20,
      inventory_manager: 21,
      vendor_creator: 22,
      vendor_reviewer: 23,
      policy_admin: 24,
      vendor_manager: 25,
      bank_payment_request_auditor: 26,
      budget_manager: 27,
      non_po_initiator: 28
  }

  VALUES_EM = {
      admin: 1,
      finance_manager: 2,
      manager: 3,
      employee: 4,
      auditor: 5,
      travel_manager: 6,
      purchaser: 7,
      receiver: 8
  }

  VALUES_VP = {
      admin: 1,
      # creditor: 2,
      reviewer: 3,
      initiator: 4,
      auditor: 5,
      travel_manager: 6,
      purchaser: 7,
      receiver: 8,
      creditor: 9,
      purchase_request_initiator: 10,
      purchase_request_reviewer: 11,
      purchase_order_initiator: 12,
      purchase_order_reviewer: 13,
      goods_receiver: 14,
      invoice_initiator: 15,
      invoice_reviewer: 16,
      bank_payment_request_initiator: 17,
      bank_payment_request_reviewer: 18,
      bank_payment_request_creditor:19,
      item_master_manager: 20,
      inventory_manager: 21,
      vendor_creator: 22,
      vendor_reviewer: 23,
      policy_admin: 24,
      vendor_manager: 25,
      bank_payment_request_auditor: 26,
      budget_manager: 27,
      non_po_initiator: 28
  }


  # This is used for segregating VP specific policies
  # Do not put user specific roles like :initiator, :creaditor, :admin, :reviewer here
  VP_ROLES = {
    purchase_request_initiator: 10,
    purchase_request_reviewer: 11,
    purchase_order_initiator: 12,
    purchase_order_reviewer: 13,
    goods_receiver: 14,
    invoice_initiator: 15,
    invoice_reviewer: 16,
    bank_payment_request_initiator: 17,
    bank_payment_request_reviewer: 18,
    bank_payment_request_creditor: 19,
    item_master_manager: 20,
    inventory_manager: 21,
    vendor_creator: 22,
    vendor_reviewer: 23,
    policy_admin: 24,
    vendor_manager: 25,
    bank_payment_request_auditor: 26,
    budget_manager: 27,
    non_po_initiator: 28
  }

  def self.seed_data
    VALUES.each do |name, value|
      if UserRole.find_by(id: value).blank?
        UserRole.create id: value, name: name
      end
    end
  end

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(role)
    role == :finance_manager if role == :finance
    VALUES[role]
  end

  def self.name_for(role_id)
    case RequestStore.store[:current_app]
      when 'em', :em
        VALUES_EM.key(role_id)
      when 'vp', :vp
        VALUES_VP.key(role_id)
      else
        VALUES.key(role_id)
    end
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
