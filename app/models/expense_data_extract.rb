# == Schema Information
#
# Table name: expense_data_extracts
#
#  id                             :integer          not null, primary key
#  merchant                       :string(255)
#  reference_id                   :string(255)
#  time                           :time
#  amount_id                      :integer
#  category_id                    :integer
#  sourcable_id                   :integer
#  sourcable_type                 :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  extractable_id                 :integer          not null
#  extractable_type               :string(255)      not null
#  note                           :text(65535)
#  datetime                       :datetime
#  expense_data_extract_source_id :integer
#  status_id                      :integer          not null
#

class ExpenseDataExtract < ApplicationRecord
  belongs_to :extractable, optional: true, polymorphic: true
  belongs_to :amount, optional: true
  belongs_to :expense_data_extract_source, optional: true
  belongs_to :category, optional: true
  belongs_to :sourcable, optional: true, polymorphic: true
  belongs_to :status, optional: true, class_name: 'ExpenseDataExtractStatus'

  accepts_nested_attributes_for :amount

  validates :expense_data_extract_source_id, presence: true

  default_scope { order(created_at: :desc) }

  scope :success, -> {where status_id: ExpenseDataExtractStatus.id_for(:success)}

end
