# == Schema Information
#
# Table name: money_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#





class MoneyRequestCommentAction < ActiveRecord::Base

  ACTIONS = {
              create: 1, retract: 2, submit: 3, approve: 4,
              approve_and_forward: 5, auto_approve: 6, reject: 7,
              unapprove: 8, take_control: 9, comment: 10, update: 11,
              credited: 12, credited_from_virtual_account_to_wallet: 13,
              credited_from_virtual_account_to_card: 14,
              credited_from_wallet_to_wallet: 15,
              credited_from_wallet_to_card: 16,
              credited_from_card_to_card: 17,
              credited_from_card_to_wallet: 18,
              created_by_delegate: 19,
              updated_by_delegate: 20,
              submitted_by_delegate: 21,
              retracted_by_delegate: 22
            }

  scope :with_name, -> (name) {where name: name}

  self.class.instance_eval do
    ACTIONS.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(action)
    ACTIONS[action]
  end

  def self.seed_data
    count = MoneyRequestCommentAction.count
    ACTIONS.each do |key, value|
      if count == 0 or MoneyRequestCommentAction.with_name(key).blank?
        MoneyRequestCommentAction.create id: value, name: key
      end
    end
  end

end
