class Procurements::Index < Procurements::Base
  attr_accessor :procurements

  def init

  end

  def process
    # Find own purchase orders
    procurement_ids = []
    if user.vendor_payments_initiator?
      procurement_ids.push(user.company.purchase_orders.with_user_id(user.id).pluck(:procurement_id))
    end

    if user.vendor_payments_reviewer?
      level_ids = []
      policies = user.company.policies.with_application(:vp)
      policies.each do |policy|
        levels = policy.levels
        levels.each do |level|
          if level.reviewers.pluck(:id).include? user.id
            level_ids.push(level.id)
          end
        end
      end

      procurement_ids.push(user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:procurement_id))
    end

    if user.vendor_payment_admin?
      procurement_ids.push(user.company.purchase_orders.pluck(:procurement_id))
    end

    self.procurements = user.company.procurements.with_ids(procurement_ids.uniq)
  end

  def success
    params[:procurements] = self.procurements
    Procurements::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements

    def init
      self.procurements = params[:procurements]
    end
  end
end