class Procurements::Index < Procurements::Base
  attr_accessor :procurements

  has_scope :filter_status_tags

  def init

  end

  def process
    # Find trail user for invoice

    procurement_ids = []

    # Find procurement from invoice trails
    invoice_trails = Trail.with_action_user_id(user.id).with_parent_type('Invoice')
    procurement_ids += user.company.inward_invoices.with_id(invoice_trails.pluck(:parent_id)).pluck(:procurement_id).uniq

    # Find procurement from purchase order trails
    purchase_order_trails = Trail.with_action_user_id(user.id).with_parent_type('PurchaseOrder')
    procurement_ids += user.company.purchase_orders.with_id(purchase_order_trails.pluck(:parent_id)).pluck(:procurement_id).uniq


    # Find own procurements
    if user.vendor_payments_initiator?
      procurement_ids.push(user.company.purchase_orders.with_user_id(user.id).pluck(:procurement_id))
    end

    # If reviewer or awaiting reviewal
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

    # If creditor: find approved, unpaid, partially paid, paid invoices and their procurements
    invoice_status_ids = [InwardInvoiceStatus.id_for(:approved), InwardInvoiceStatus.id_for(:unpaid), InwardInvoiceStatus.id_for(:partially_paid), InwardInvoiceStatus.id_for(:paid)]
    procurement_ids.push user.company.inward_invoices.with_procurement.with_status_id(invoice_status_ids).pluck(:procurement_id)


    # If admin, select all procurements
    if user.vendor_payment_admin?
      procurement_ids.push(user.company.purchase_orders.pluck(:procurement_id))
    end

    self.procurements = user.company.procurements.with_ids(procurement_ids.uniq)

    # find procurement status taggables
    # self.procurements = user.company.procurements
    #
    # if params[:filter_status_tags].present? && params[:filter_status_tags].is_a?(Array)
    #   all_status_tag_ids = StatusTag.all.pluck(:id)
    #   status_tag_ids = all_status_tag_ids & params[:filter_status_tags].map(&:to_i)
    #
    #   procurement_status_taggables = ProcurementStatusTaggable.with_status_tag_ids(status_tag_ids).with_procurement_ids(procurements.pluck(:id))
    #
    #   filter_procurement_ids = procurement_status_taggables.pluck(:procurement_id)
    #
    #   self.procurements = self.procurements.with_ids(filter_procurement_ids)
    # end

    # # Find own purchase orders
    # procurement_ids = []
    # if user.vendor_payments_initiator?
    #   procurement_ids.push(user.company.purchase_orders.with_user_id(user.id).pluck(:procurement_id))
    # end

    # if user.vendor_payments_reviewer?
    #   level_ids = []
    #   policies = user.company.policies.with_application(:vp)
    #   policies.each do |policy|
    #     levels = policy.levels
    #     levels.each do |level|
    #       if level.reviewers.pluck(:id).include? user.id
    #         level_ids.push(level.id)
    #       end
    #     end
    #   end
    #
    #   procurement_ids.push(user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:procurement_id))
    # end

    # if user.vendor_payment_admin?
    #   procurement_ids.push(user.company.purchase_orders.pluck(:procurement_id))
    # end
    #
    # self.procurements = self.procurements.with_ids(procurement_ids.uniq)
  end

  def success
    params[:procurements] = self.procurements
    Procurements::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements, :paginated_procurements

    def init
      self.procurements = params[:procurements]
      apply_filter
      self.paginated_procurements = self.procurements.order_by_controlling_user(user.id)
    end

    def apply_filter
      if params[:filter_status_tags].present? && params[:filter_status_tags].is_a?(Array)
        all_status_tag_ids = StatusTag.all.pluck(:id)
        status_tag_ids = all_status_tag_ids & params[:filter_status_tags].map(&:to_i)

        procurement_status_taggables = ProcurementStatusTaggable.with_status_tag_ids(status_tag_ids).with_procurement_ids(procurements.pluck(:id))

        filter_procurement_ids = procurement_status_taggables.pluck(:procurement_id)

        self.procurements = self.procurements.with_ids(filter_procurement_ids)
      end
    end

  end
end