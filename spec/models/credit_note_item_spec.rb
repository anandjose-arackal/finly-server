# == Schema Information
#
# Table name: credit_note_items
#
#  id                         :bigint           not null, primary key
#  credit_note_id             :integer
#  item_id                    :integer
#  invoice_item_id            :integer
#  category_id                :integer
#  credit_note_item_type_id   :integer
#  comment                    :text(65535)
#  gl_code                    :string(255)
#  hsn_sac                    :string(255)
#  original_quantity          :decimal(20, 5)
#  revised_quantity           :decimal(20, 5)
#  quantity                   :decimal(20, 5)
#  original_rate              :decimal(20, 5)
#  revised_rate               :decimal(20, 5)
#  rate                       :decimal(20, 5)
#  original_taxable_amount_id :integer
#  revised_taxable_amount_id  :integer
#  taxable_amount_id          :integer
#  original_tax_rate_id       :integer
#  revised_tax_rate_id        :integer
#  tax_rate_id                :integer
#  total_amount_id            :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  deleted_at                 :datetime
#  tax_amount_id              :integer
#

require 'rails_helper'

RSpec.describe CreditNoteItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
