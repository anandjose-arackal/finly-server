# == Schema Information
#
# Table name: payment_agreement_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class PaymentAgreementStatus < ApplicationRecord

  include Seedable

  GROUP_AWAITING_APPROVAL = 91

  def self.values
    [
        :draft,
        :awaiting_approval,
        :approved,
        :auto_approved,
        :retracted,
        :rejected,
        :closed,
        :invoice_created,
        :payment_ticket_created,
        :terminated,
        :revised
    ]
  end

  def retracted?
    self.id == PaymentAgreementStatus.id_for(:retracted)
  end

  def rejected?
    self.id == PaymentAgreementStatus.id_for(:rejected)
  end

  def approved?
    self.id == PaymentAgreementStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == PaymentAgreementStatus.id_for(:auto_approved)
  end


  def closed?
    self.id == PaymentAgreementStatus.id_for(:closed)
  end

  def draft?
    self.id == PaymentAgreementStatus.id_for(:draft)
  end

  def awaiting_approval?
    self.id == PaymentAgreementStatus.id_for(:awaiting_approval)
  end

  def terminated?
    self.id == PaymentAgreementStatus.id_for(:terminated)
  end

  def revised?
    self.id == PaymentAgreementStatus.id_for(:revised)
  end

end
