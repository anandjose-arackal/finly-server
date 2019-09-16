class MissingDLRM
  attr_accessor :approved_purchase_orders, :processing_purchase_orders, :other_purchase_orders,
    :processing_invoices, :approved_invoices, :other_invoices, :time_taken,
    :result

  def initialize
    company_ids = [118, 140] 
    po_approve_status_ids =  PurchaseOrder.status_ids(:approved, :auto_approved, :sent_to_vendor, :closed, :vendor_confirmed)
    approved_purchase_order_ids = PurchaseOrder.where(company_id: company_ids, purchase_order_status_id: po_approve_status_ids).pluck(:id)

    po_processing_status_ids = PurchaseOrder.status_ids(:processing)
    processing_purchase_order_ids = PurchaseOrder.where(company_id: company_ids, purchase_order_status_id: po_processing_status_ids).pluck(:id)

    po_other_status_ids = PurchaseOrder.status_ids(:open, :retracted, :rejected)
    other_purchase_order_ids = PurchaseOrder.where(company_id: company_ids, purchase_order_status_id: po_other_status_ids).where.not(policy_id: nil).pluck(:id)

    #Invoices
    #["unpaid", "paid", "open", "retracted", "processing", "approved", "rejected", "auto_approved"]
    invoice_approve_status_ids =  Invoice.status_ids(:approved, :paid)
    approved_invoice_ids = Invoice.where(company_id: company_ids, invoice_status_id: invoice_approve_status_ids).where.not(procurement_id: nil).pluck(:id)

    invoice_processing_status_ids =  Invoice.status_ids(:processing)
    processing_invoice_ids = Invoice.where(company_id: company_ids, invoice_status_id: invoice_processing_status_ids).where.not(procurement_id: nil).pluck(:id)

    invoice_other_status_ids = Invoice.status_ids(:open, :retracted, :rejected) 
    other_invoice_ids = Invoice.where(company_id: company_ids, invoice_status_id: invoice_other_status_ids).where.not(policy_id: nil).where.not(procurement_id: nil).pluck(:id)

    self.processing_purchase_orders = PurchaseOrder.with_id(processing_purchase_order_ids)
    self.approved_purchase_orders = PurchaseOrder.with_id(approved_purchase_order_ids)
    self.other_purchase_orders = PurchaseOrder.with_id(other_purchase_order_ids)

    self.processing_invoices = Invoice.with_id(processing_invoice_ids)
    self.approved_invoices = Invoice.with_id(approved_invoice_ids)
    self.other_invoices = Invoice.with_id(other_invoice_ids)

    # Results
    self.result = {
      error: [],
      policy_error: []
    }
  end

  # Approved
  # 1. For every approve action create dlrm
  # 2. remove duplicate where level number is same

  # For open, use set method

  # Processing:
  # - 

  ############################## Purchase Order START ##############################
  def process
    start_time = Time.now

    self.approved_purchase_orders.each do |po|
      policy = po.policy

      # Find approved trails
      trails = po.trails.with_action_id(TrailAction.id_for(:approve)).reorder(:created_at)

      # Delete previous dlrms
      old_dlrms = po.document_level_reviewer_mappings
      old_dlrms.destroy_all

      trails.each do |trail|
        level = trail.action_level

        threshold = level.level_reviewer_mappings.with_reviewer_id(trail.action_user_id).first.threshold rescue 0

        dlrm = po.document_level_reviewer_mappings.create(
          policy_id: level.policy_id,
          level_id: level.id,
          level_number: level.level_number,
          reviewer_id: trail.action_user_id,
          taken_control: false,
          viewable: true,
          action_taken_by_id: trail.action_user_id,
          action_id: trail.action_id,
          provider_name: 'PurchaseOrderProvider',
          threshold: threshold
        )
      end
    end

    self.processing_purchase_orders.each do |po|
      policy = po.policy

      # Delete any dlrms where levels are not from current policy
      po.document_level_reviewer_mappings.where.not(policy_id: policy.id).destroy_all

      # Delete previous dlrms
      old_dlrms = DocumentLevelReviewerMapping.where(id: po.document_level_reviewer_mappings.reload.pluck(:id))

      # p old_dlrms.pluck(:id)

      already_created_dlrm_ids = []
      to_be_deleted_dlrms = DocumentLevelReviewerMapping.where(id: po.document_level_reviewer_mappings.reload.pluck(:id))
      # p to_be_deleted_dlrms.pluck(:id)
      # old_dlrms.destroy_all

      new_dlrms = []

      # Find approved trails
      trails = po.trails.with_action_id(TrailAction.id_for(:approve)).reorder(:created_at)

      trails.each do |trail|

        level = trail.action_level

        threshold = level.level_reviewer_mappings.with_reviewer_id(trail.action_user_id).first.threshold rescue 0

        dlrm = po.document_level_reviewer_mappings.create(
          policy_id: level.policy_id,
          level_id: level.id,
          level_number: level.level_number,
          reviewer_id: trail.action_user_id,
          taken_control: false,
          viewable: true,
          action_taken_by_id: trail.action_user_id,
          action_id: trail.action_id,
          provider_name: 'PurchaseOrderProvider',
          threshold: threshold
        )

        # save the new dlrms
        new_dlrms.push(dlrm)

        # save already created dlrms's ids
        already_created_dlrm_ids += old_dlrms.select{|x| ((x.level_id == level.id) && (x.reviewer_id.blank? || x.reviewer_id == trail.action_user_id))}.pluck(:id)
        # old_dlrms = old_dlrms.reject{|x| ((x.level_id == level.id) && (x.reviewer_id.blank? || x.reviewer_id == trail.action_user_id)) }

      end

      rest_of_dlrm = DocumentLevelReviewerMapping.where(id: po.document_level_reviewer_mappings.reload.where.not(id: already_created_dlrm_ids).pluck(:id))

      # p rest_of_dlrm.pluck(:id)

      policy.levels.with_associated_entity_type('PurchaseOrderProvider').each do |level|
        unless new_dlrms.map(&:level_id).include?(level.id)
          reviewer_ids = level.level_reviewer_mappings.reload.non_deleted.with_threshold(po.balance_amount.value).pluck(:reviewer_id)

          old_dlrm = rest_of_dlrm.where(level_id: level.id).first

          if old_dlrm.present?

            if reviewer_ids.include?(old_dlrm.reviewer_id) || old_dlrm.reviewer_id.blank?

              reviewer_id = old_dlrm.reviewer_id.blank? ? reviewer_ids[0] : old_dlrm.reviewer_id

              threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_id).first.threshold rescue 0
              new_dlrm = po.document_level_reviewer_mappings.create(
                policy_id: level.policy_id,
                level_id: level.id,
                level_number: level.level_number,
                reviewer_id: reviewer_id,
                taken_control: false,
                viewable: false,
                action_taken_by_id: nil,
                action_id: nil,
                provider_name: 'PurchaseOrderProvider',
                threshold: threshold
                )
              new_dlrms.push(new_dlrm)

              already_created_dlrm_ids += rest_of_dlrm.select{|x| (x.id == old_dlrm.id)}.pluck(:id)
            else
              error_data = {
                purchase_order_id: po.id,
                level_number: level.level_number,
                level_id: level.id,
                old_dlrm: old_dlrm,
                reviewer_ids: reviewer_ids
              }
              self.result[:error].push(error_data)
            end
          else
            threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_ids.first).first.threshold rescue 0
            new_dlrm = po.document_level_reviewer_mappings.create(
              policy_id: level.policy_id,
              level_id: level.id,
              level_number: level.level_number,
              reviewer_id: reviewer_ids.first,
              taken_control: false,
              viewable: false,
              action_taken_by_id: nil,
              action_id: nil,
              provider_name: 'PurchaseOrderProvider',
              threshold: threshold
              )
            new_dlrms.push(new_dlrm)
          end
        end
      end

      # Delete old dlrms where new has been created for it
      po.document_level_reviewer_mappings.reload.where(id: already_created_dlrm_ids).destroy_all

      # controlling level
      controlling_level_id = po.controlling_level_id

      controlling_dlrm = po.document_level_reviewer_mappings.reload.where(level_id: controlling_level_id).first

      if controlling_dlrm.present?
        po.document_level_reviewer_mappings.where("level_number <= ?", controlling_dlrm.level_number).update_all(viewable: true)
      end

    end

    self.other_purchase_orders.each do |document|

      policy = document.policy

      # Delete any dlrms where levels are not from current policy
      document.document_level_reviewer_mappings.where.not(policy_id: policy.id).destroy_all

      # Delete previous dlrms
      old_dlrms = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.pluck(:id))

      # p old_dlrms.pluck(:id)

      already_created_dlrm_ids = []
      to_be_deleted_dlrms = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.pluck(:id))
      # p old_dlrms.pluck(:id)
      # old_dlrms.destroy_all

      new_dlrms = []

      # Find approved trails
      # trails = po.trails.with_action_id(TrailAction.id_for(:approve)).reorder(:created_at)

      # trails.each do |trail|

      #   level = trail.action_level

      #   dlrm = po.document_level_reviewer_mappings.create(
      #     policy_id: level.policy_id,
      #     level_id: level.id,
      #     level_number: level.level_number,
      #     reviewer_id: trail.action_user_id,
      #     taken_control: false,
      #     viewable: true,
      #     action_taken_by_id: trail.action_user_id,
      #     action_id: trail.action_id,
      #     provider_name: 'PurchaseOrderProvider',
      #     threshold: level.level_reviewer_mappings.with_reviewer_id(trail.action_user_id).first.threshold
      #   )

      #   # save the new dlrms
      #   new_dlrms.push(dlrm)

      #   # save already created dlrms's ids
      #   already_created_dlrm_ids += old_dlrms.select{|x| ((x.level_id == level.id) && (x.reviewer_id.blank? || x.reviewer_id == trail.action_user_id))}.pluck(:id)
      #   # old_dlrms = old_dlrms.reject{|x| ((x.level_id == level.id) && (x.reviewer_id.blank? || x.reviewer_id == trail.action_user_id)) }
      # end

      # rest_of_dlrm = po.document_level_reviewer_mappings.reload.where.not(id: already_created_dlrm_ids)

      policy.levels.with_associated_entity_type('PurchaseOrderProvider').each do |level|
        amount = document.balance_amount&.value || 0
          reviewer_ids = level.level_reviewer_mappings.reload.non_deleted.with_threshold(amount).pluck(:reviewer_id)

          old_dlrm = old_dlrms.where(level_id: level.id).first

          if old_dlrm.present?

            if reviewer_ids.include?(old_dlrm.reviewer_id) || old_dlrm.reviewer_id.blank?

              reviewer_id = old_dlrm.reviewer_id.blank? ? reviewer_ids[0] : old_dlrm.reviewer_id

              threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_id).first.threshold rescue 0
              new_dlrm = document.document_level_reviewer_mappings.create(
                policy_id: level.policy_id,
                level_id: level.id,
                level_number: level.level_number,
                reviewer_id: reviewer_id,
                taken_control: false,
                viewable: false,
                action_taken_by_id: nil,
                action_id: nil,
                provider_name: 'PurchaseOrderProvider',
                threshold: threshold
                )
              new_dlrms.push(new_dlrm)

              already_created_dlrm_ids.push old_dlrm.id
            else
              error_data = {
                type: "OTHER Purchase Order",
                purchase_order_id: document.id,
                level_number: level.level_number,
                level_id: level.id,
                old_dlrm: old_dlrm,
                reviewer_ids: reviewer_ids
              }
              self.result[:error].push(error_data)
            end
          else
            threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_ids.first).first.threshold rescue 0
            new_dlrm = document.document_level_reviewer_mappings.create(
              policy_id: level.policy_id,
              level_id: level.id,
              level_number: level.level_number,
              reviewer_id: reviewer_ids.first,
              taken_control: false,
              viewable: false,
              action_taken_by_id: nil,
              action_id: nil,
              provider_name: 'PurchaseOrderProvider',
              threshold: threshold
              )
            new_dlrms.push(new_dlrm)
          end
      end

      # Delete old dlrms where new has been created for it
      document.document_level_reviewer_mappings.reload.where(id: already_created_dlrm_ids).destroy_all

      # # controlling level
      # controlling_level_id = po.controlling_level_id

      # controlling_dlrm = po.document_level_reviewer_mappings.reload.where(level_id: controlling_level_id).first

      document.document_level_reviewer_mappings.update_all(viewable: false)
    end


    self.approved_invoices.each do |document|
      policy = Policy.find document.policy_id

      # Find approved trails
      trails = document.trails.with_action_id(TrailAction.id_for(:approve)).reorder(:created_at)

      # Delete previous dlrms
      old_dlrms = document.document_level_reviewer_mappings
      old_dlrms.destroy_all

      trails.each do |trail|
        level = trail.action_level

        threshold = level.level_reviewer_mappings.with_reviewer_id(trail.action_user_id).first.threshold rescue 0

        dlrm = document.document_level_reviewer_mappings.create(
          policy_id: level.policy_id,
          level_id: level.id,
          level_number: level.level_number,
          reviewer_id: trail.action_user_id,
          taken_control: false,
          viewable: true,
          action_taken_by_id: trail.action_user_id,
          action_id: trail.action_id,
          provider_name: 'InvoiceProvider',
          threshold: threshold
        )
      end
    end

    self.processing_invoices.each do |document|
      policy = Policy.find document.policy_id

      # Delete any dlrms where levels are not from current policy
      document.document_level_reviewer_mappings.where.not(policy_id: policy.id).destroy_all

      # Delete previous dlrms
      old_dlrms = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.pluck(:id))

      # p old_dlrms.pluck(:id)

      already_created_dlrm_ids = []
      to_be_deleted_dlrms = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.pluck(:id))
      # p to_be_deleted_dlrms.pluck(:id)
      # old_dlrms.destroy_all

      new_dlrms = []

      # Find approved trails
      trails = document.trails.with_action_id(TrailAction.id_for(:approve)).reorder(:created_at)

      trails.each do |trail|

        level = trail.action_level

        threshold = level.level_reviewer_mappings.with_reviewer_id(trail.action_user_id).first.threshold rescue 0

        dlrm = document.document_level_reviewer_mappings.create(
          policy_id: level.policy_id,
          level_id: level.id,
          level_number: level.level_number,
          reviewer_id: trail.action_user_id,
          taken_control: false,
          viewable: true,
          action_taken_by_id: trail.action_user_id,
          action_id: trail.action_id,
          provider_name: 'InvoiceProvider',
          threshold: threshold
        )

        # save the new dlrms
        new_dlrms.push(dlrm)

        # save already created dlrms's ids
        already_created_dlrm_ids += old_dlrms.select{|x| ((x.level_id == level.id) && (x.reviewer_id.blank? || x.reviewer_id == trail.action_user_id))}.pluck(:id)
        # old_dlrms = old_dlrms.reject{|x| ((x.level_id == level.id) && (x.reviewer_id.blank? || x.reviewer_id == trail.action_user_id)) }
      end

      rest_of_dlrm = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.where.not(id: already_created_dlrm_ids).pluck(:id))

      # p rest_of_dlrm.pluck(:id)

      policy.levels.with_associated_entity_type('InvoiceProvider').each do |level|
        unless new_dlrms.map(&:level_id).include?(level.id)
          reviewer_ids = level.level_reviewer_mappings.reload.non_deleted.with_threshold(document.net_amount.value).pluck(:reviewer_id)

          old_dlrm = rest_of_dlrm.where(level_id: level.id).first

          if old_dlrm.present?

            if reviewer_ids.include?(old_dlrm.reviewer_id) || old_dlrm.reviewer_id.blank?

              reviewer_id = old_dlrm.reviewer_id.blank? ? reviewer_ids[0] : old_dlrm.reviewer_id

              threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_id).first.threshold rescue 0
              new_dlrm = document.document_level_reviewer_mappings.create(
                policy_id: level.policy_id,
                level_id: level.id,
                level_number: level.level_number,
                reviewer_id: reviewer_id,
                taken_control: false,
                viewable: false,
                action_taken_by_id: nil,
                action_id: nil,
                provider_name: 'InvoiceProvider',
                threshold: threshold
                )
              new_dlrms.push(new_dlrm)

              already_created_dlrm_ids += rest_of_dlrm.select{|x| (x.id == old_dlrm.id)}.pluck(:id)
            else
              error_data = {
                invoice_id: document.id,
                level_number: level.level_number,
                level_id: level.id,
                old_dlrm: old_dlrm,
                reviewer_ids: reviewer_ids
              }
              self.result[:error].push(error_data)
            end
          else
            threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_ids.first).first.threshold rescue 0
            new_dlrm = document.document_level_reviewer_mappings.create(
              policy_id: level.policy_id,
              level_id: level.id,
              level_number: level.level_number,
              reviewer_id: reviewer_ids.first,
              taken_control: false,
              viewable: false,
              action_taken_by_id: nil,
              action_id: nil,
              provider_name: 'InvoiceProvider',
              threshold: threshold
              )
            new_dlrms.push(new_dlrm)
          end
        end
      end

      # Delete old dlrms where new has been created for it
      document.document_level_reviewer_mappings.reload.where(id: already_created_dlrm_ids).destroy_all

      # controlling level
      controlling_level_id = document.controlling_level_id

      controlling_dlrm = document.document_level_reviewer_mappings.reload.where(level_id: controlling_level_id).first

      if controlling_dlrm.present?
        document.document_level_reviewer_mappings.where("level_number <= ?", controlling_dlrm.level_number).update_all(viewable: true)
      end
    end

    self.other_invoices.each do |document|

      policy = Policy.find(document.policy_id)

      # Delete any dlrms where levels are not from current policy
      document.document_level_reviewer_mappings.where.not(policy_id: policy.id).destroy_all

      # Delete previous dlrms
      old_dlrms = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.pluck(:id))

      # p old_dlrms.pluck(:id)

      already_created_dlrm_ids = []
      to_be_deleted_dlrms = DocumentLevelReviewerMapping.where(id: document.document_level_reviewer_mappings.reload.pluck(:id))
      # p to_be_deleted_dlrms.pluck(:id)
      # old_dlrms.destroy_all

      new_dlrms = []

      policy.levels.with_associated_entity_type('InvoiceProvider').each do |level|
        amount = document.net_amount&.value || 0
          reviewer_ids = level.level_reviewer_mappings.reload.non_deleted.with_threshold(amount).pluck(:reviewer_id)

          old_dlrm = old_dlrms.where(level_id: level.id).first

          if old_dlrm.present?

            if reviewer_ids.include?(old_dlrm.reviewer_id) || old_dlrm.reviewer_id.blank?

              reviewer_id = old_dlrm.reviewer_id.blank? ? reviewer_ids[0] : old_dlrm.reviewer_id
              threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_id).first.threshold rescue 0
              new_dlrm = document.document_level_reviewer_mappings.create(
                policy_id: level.policy_id,
                level_id: level.id,
                level_number: level.level_number,
                reviewer_id: reviewer_id,
                taken_control: false,
                viewable: false,
                action_taken_by_id: nil,
                action_id: nil,
                provider_name: 'InvoiceProvider',
                threshold: threshold
                )
              new_dlrms.push(new_dlrm)

              already_created_dlrm_ids.push old_dlrm.id
            else
              error_data = {
                type: "OTHER Invoice",
                purchase_order_id: document.id,
                level_number: level.level_number,
                level_id: level.id,
                old_dlrm: old_dlrm,
                reviewer_ids: reviewer_ids
              }
              self.result[:error].push(error_data)
            end
          else
            threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer_ids.first).first.threshold rescue 0
            new_dlrm = document.document_level_reviewer_mappings.create(
              policy_id: level.policy_id,
              level_id: level.id,
              level_number: level.level_number,
              reviewer_id: reviewer_ids.first,
              taken_control: false,
              viewable: false,
              action_taken_by_id: nil,
              action_id: nil,
              provider_name: 'InvoiceProvider',
              threshold: threshold
              )
            new_dlrms.push(new_dlrm)
          end
      end

      # Delete old dlrms where new has been created for it
      document.document_level_reviewer_mappings.reload.where(id: already_created_dlrm_ids).destroy_all

      # # controlling level
      # controlling_level_id = po.controlling_level_id

      # controlling_dlrm = po.document_level_reviewer_mappings.reload.where(level_id: controlling_level_id).first

      document.document_level_reviewer_mappings.update_all(viewable: false)
    end

    end_time = Time.now

    self.time_taken = end_time - start_time


  end
end