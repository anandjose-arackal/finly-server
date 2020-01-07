# == Schema Information
#
# Table name: post_operation_actions
#
#  id                   :integer          not null, primary key
#  operation            :string(255)      not null
#  payload              :text(65535)
#  post_operatable_id   :integer          not null
#  post_operatable_type :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class PostOperationAction < ApplicationRecord

  serialize :payload

  belongs_to :post_operatable, optional: true, polymorphic: true

  validates :post_operatable, presence: true
  validates :operation, presence: true
  validate :is_valid_operation?

  def is_valid_operation?
    obj = Object.const_get(operation)
    unless obj.present?
      self.errors.add :operation, 'is not a valid class'
      return
    end
    is_finly_operation = obj.try(:is_finly_post_operation?) rescue nil
    unless is_finly_operation
      self.errors.add :operation, 'is not a finly post operation class'
      return
    end
  end

end
