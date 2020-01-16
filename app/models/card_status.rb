# == Schema Information
#
# Table name: card_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class CardStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unassigned, :assign_requested, :assigned, :upgrade_requested, :upgraded, :expired, :hotlisted]
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
