# == Schema Information
#
# Table name: booking_others
#
#  id              :integer          not null, primary key
#  parent_id       :integer
#  parent_type     :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  booking_details :text(65535)
#  description     :text(65535)
#  cost_id         :integer
#  is_deleted      :boolean          default(FALSE)
#  booking_id      :integer
#  deleted_at      :datetime
#

class BookingOther < ApplicationRecord
  include SoftDeletable

  # belongs_to :parent, optional: true, polymorphic: true
  belongs_to :booking, optional: true, inverse_of: :booking_other
  belongs_to :cost, optional: true, class_name: 'Amount', dependent: :destroy

  def as_json(options={})
    {
        id: id,
        booking_details: booking_details,
        description: description,
        cost: cost
    }
  end
end
