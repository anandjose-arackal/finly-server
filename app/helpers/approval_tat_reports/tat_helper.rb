module ApprovalTatReports::TatHelper
    
    def export_report(documents,route)
      tat_reports = []
      case route.upcase
      when "INVOICES"
        return invoice_tat_report(documents, tat_reports)
      when "PURCHASE_REQUESTS"
        return purchase_request_tat_report(documents, tat_reports)
      when "PURCHASE_ORDERS"
        return purchase_order_tat_report(documents, tat_reports)
      when "PAYMENT_TICKETS"
        return bank_payment_request_tat_report(documents, tat_reports)
      when "AGREEMENTS"
        return payment_agreement_tat_report(documents, tat_reports)
      when "UTILITY_SUBSCRIPTIONS"
        return bbps_biller_subscriptions_tat_report(documents, tat_reports)
      end
    end

    def invoice_tat_report(documents, tat_reports)
      documents = documents.where.not(invoice_status_id: InwardInvoiceStatus.id_for(:open))
      documents&.each do |document|
        data = {}
        data[:invoice_id] = document&.invoice_id
        data[:business_name] = document&.vendor&.business_name
        data[:trade_name] = document&.vendor&.trade_name
        data[:policy_name] = document&.policy&.name
        data[:invoice_number] = document&.invoice_number
        data[:invoice_date] = document&.date&.to_date&.strftime("%d-%m-%Y")
        data[:invoice_amount] = document&.invoice_total_amount
        data[:po_number] = (document&.po_number ||= "")
        data[:invoice_submitted_by] = "#{document&.created_by&.first_name} #{document&.created_by&.last_name}"
        data[:invoice_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        data[:interval_between_invoice_date_to_invoice_submission] = (document&.date && document&.submitted_at) ? ((document&.date&.to_date - document&.submitted_at&.to_date).to_i)&.abs : ""
        
        last_level_approval_date = document.submitted_at&.to_date&.strftime("%d-%m-%Y")
        invoice_reviewal_chain = document&.get_reviewal_chain
        invoice_last_approval_level = invoice_reviewal_chain&.last ? invoice_reviewal_chain&.last[:level_number] : ""
        invoice_approval_levels = (1..invoice_last_approval_level&.to_i).to_a
        invoice_actual_approval_levels = invoice_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

        assign_reviewers_data(data, invoice_approval_levels, invoice_actual_approval_levels, invoice_reviewal_chain, last_level_approval_date)

        invoice_payment_ticket = document&.payments&.order(created_at: :desc)&.first&.payment_order&.bank_payment_request

        data[:payment_ticket_created_by] = "#{invoice_payment_ticket&.created_by&.first_name} #{invoice_payment_ticket&.created_by&.last_name}"
        payment_ticket_created_at = invoice_payment_ticket&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        data[:payment_ticket_created_date] = payment_ticket_created_at ? payment_ticket_created_at : ""
        data[:interval_between_approval_to_payment_ticket_creation] = (invoice_payment_ticket&.approved_at && payment_ticket_created_at) ? ( invoice_payment_ticket&.approved_at&.to_date - payment_ticket_created_at&.to_date ).to_i : ""
        
        last_level_approval_date = payment_ticket_created_at
        current_level_approval_date = ""
        pt_reviewal_chain = invoice_payment_ticket&.get_reviewal_chain
        pt_last_level = pt_reviewal_chain&.last ? pt_reviewal_chain&.last[:level_number] : ""
        pt_approval_levels = (1..pt_last_level&.to_i).to_a
        pt_actual_approval_levels = pt_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}
        
        pt_approval_levels&.each do |each_level|
          if pt_actual_approval_levels.include?(each_level)
            selected_level_reviewer = pt_reviewal_chain&.select { |review_chain| review_chain[:level_number].to_s == each_level.to_s }&.first
            data["level_#{each_level}_payment_ticket_approver_name"] =  selected_level_reviewer[:action_taken] ? fetch_approver_name(selected_level_reviewer) : ""
            current_level_approval_date = selected_level_reviewer[:action_taken] ? selected_level_reviewer[:action_taken_at]&.to_date&.strftime("%d-%m-%Y") : ""
            data["level_#{each_level}_payment_ticket_approval_date"] = current_level_approval_date
            data["level_#{each_level}_payment_ticket_interval_from_last_level"] = (current_level_approval_date.present? && last_level_approval_date.present?) ? (current_level_approval_date&.to_date - last_level_approval_date&.to_date).to_i : ""
            last_level_approval_date = current_level_approval_date
          else
            data["level_#{each_level}_approver_name"] = ""
            data["level_#{each_level}_approval_date"]  = ""
            data["level_#{each_level}_interval_from_last_level"] = ""
          end
        end

        data["invoice_ageing"] = find_ageing_days(document)
        tat_reports.push(data)
      end
      return tat_data(tat_reports)
    end

    def purchase_request_tat_report(documents, tat_reports)
      documents = documents.where.not(purchase_request_status_id: PurchaseRequestStatus.id_for(:draft))
      documents&.each do |document|
        data = {}
        data[:purchase_request_no] = document&.order_number
        data[:policy_name] = document&.policy&.name
        data[:pr_amount] = document&.total_amount&.value
        data[:pr_submitted_by] = "#{document&.creator&.first_name} #{document.creator&.last_name}"
        data[:pr_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = document&.submitted_at&.to_date.strftime("%d-%m-%Y")
        pr_reviewal_chain = document&.get_reviewal_chain
        pr_last_approval_level = pr_reviewal_chain&.last ? pr_reviewal_chain&.last[:level_number] : ""
        pr_approval_levels = (1..pr_last_approval_level&.to_i).to_a
        pr_actual_approval_levels = pr_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

        assign_reviewers_data(data, pr_approval_levels, pr_actual_approval_levels, pr_reviewal_chain, last_level_approval_date)

        data[:pr_ageing] = (document&.submitted_at && last_level_approval_date) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.to_i : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def purchase_order_tat_report(documents, tat_reports)
      documents = documents.where.not(purchase_order_status_id: PurchaseOrderStatus.id_for(:open))
      documents&.each do |document|
        data = {}
        data[:purchase_order_no] = document&.po_number
        data[:vendor_name] = document&.vendor&.business_name
        data[:policy_name] = document&.policy&.name
        data[:po_amount] = document&.total_after_tax&.value
        data[:po_submitted_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:po_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        po_reviewal_chain = document&.get_reviewal_chain
        po_last_approval_level = po_reviewal_chain&.last ? po_reviewal_chain&.last[:level_number] : ""
        po_approval_levels = (1..po_last_approval_level&.to_i).to_a
        po_actual_approval_levels = po_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

        assign_reviewers_data(data, po_approval_levels, po_actual_approval_levels, po_reviewal_chain, last_level_approval_date)

        data[:po_ageing] = (document&.created_at && last_level_approval_date) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.to_i : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def bank_payment_request_tat_report(documents, tat_reports)
      documents = documents.where.not(status_id: BankPaymentRequestStatus.id_for(:open))
      documents&.each do |document|
        data = {}
        data[:payment_ticket_created_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        payment_ticket_created_at = document&.created_at&.to_date&.strftime("%d-%m-%Y")
        data[:payment_ticket_created_date] = payment_ticket_created_at
        data[:interval_between_approval_to_payment_ticket_creation] = (payment_ticket_created_at && document&.approved_at) ? (payment_ticket_created_at.to_date - document&.approved_at&.to_date).to_i : "" 

        last_level_approval_date = document&.created_at&.to_date&.strftime("%d-%m-%Y")
        bpr_reviewal_chain = document&.get_reviewal_chain
        bpr_last_approval_level = bpr_reviewal_chain&.last ? bpr_reviewal_chain&.last[:level_number] : ""
        bpr_approval_levels = (1..bpr_last_approval_level&.to_i).to_a
        bpr_actual_approval_levels = bpr_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

        assign_reviewers_data(data, bpr_approval_levels, bpr_actual_approval_levels, bpr_reviewal_chain, last_level_approval_date)

        data[:payment_ageing] = (document&.submitted_at && last_level_approval_date) ? ( last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.to_i : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def payment_agreement_tat_report(documents, tat_reports)
      documents = documents.where.not(status_id: PaymentAgreementStatus.id_for(:draft))
      documents&.each do |document|
        data = {}
        data[:agreement_no] = document&.order_number
        # data[:vendor_name] = document&.vendor&.business_name
        data[:policy_name] = document&.policy&.name
        data[:agrement_amount] = document&.total_amount&.value
        data[:agreement_submitted_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:agreement_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        pa_reviewal_chain = document&.get_reviewal_chain
        pa_last_approval_level = pa_reviewal_chain&.last ? pa_reviewal_chain&.last[:level_number] : ""
        pa_approval_levels = (1..pa_last_approval_level&.to_i).to_a
        pa_actual_approval_levels = pa_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

        assign_reviewers_data(data, pa_approval_levels, pa_actual_approval_levels, pa_reviewal_chain, last_level_approval_date)

        data[:agrement_ageing] = (document&.submitted_at && last_level_approval_date) ? ( last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.to_i : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def bbps_biller_subscriptions_tat_report(documents, tat_reports)
      documents = documents.where.not(status_id: BbpsBillerSubscriptionStatus.id_for(:draft))
      documents&.each do |document|
        data = {}
        data[:utility_id] = document&.sequence_id
        data[:vendor_name] = document&.biller&.biller_name
        data[:policy_name] = document&.policy&.name
        data[:utility_master_submitted_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:utility_master_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        bbps_reviewal_chain = document&.get_reviewal_chain
        bbps_last_approval_level = bbps_reviewal_chain&.last ? bbps_reviewal_chain&.last[:level_number] : ""
        bbps_approval_levels = (1..bbps_last_approval_level&.to_i).to_a
        bbps_actual_approval_levels = bbps_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

        assign_reviewers_data(data, bbps_approval_levels, bbps_actual_approval_levels, bbps_reviewal_chain, last_level_approval_date)

        data[:utility_ageing ] = (document&.submitted_at && last_level_approval_date) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.to_i : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def fetch_approver_name(review_chain)
      reviewer = review_chain.dig(:reviewers).select{ |each_reviewer| each_reviewer.dig(:action_taken)}

      if reviewer.present?
        return reviewer.first.dig(:name)
      else
        return review_chain.dig(:taken_control_by,:name)
      end

    end

    def find_ageing_days(document)
      payment = document&.payments&.order(created_at: :desc)&.first&.processed_at
      ( document&.date && payment ) ? (payment&.to_date - document&.date&.to_date).to_i : ""
    end

    def assign_reviewers_data(data, approval_levels, actual_approval_leves, review_chain, last_level_approval_date)
      approval_levels&.each do |each_level|
        if actual_approval_leves.include?(each_level)
          selected_level_reviewer = review_chain&.select { |review_chain| review_chain[:level_number].to_s == each_level.to_s }&.first
          data["level_#{each_level}_approver_name"] = selected_level_reviewer[:action_taken] ? fetch_approver_name(selected_level_reviewer) : ""
          current_level_approval_date = (selected_level_reviewer[:action_taken] ? selected_level_reviewer[:action_taken_at] : "")
          data["level_#{each_level}_approval_date"]  = current_level_approval_date&.to_date&.strftime("%d-%m-%Y")
          data["level_#{each_level}_interval_from_last_level"] = ((current_level_approval_date&.present? && last_level_approval_date&.present?) ? (current_level_approval_date&.to_date - last_level_approval_date&.to_date).to_i : "")
          last_level_approval_date = current_level_approval_date
        else
          data["level_#{each_level}_approver_name"] = ""
          data["level_#{each_level}_approval_date"] = ""
          data["level_#{each_level}_interval_from_last_level"] = ""
        end
      end
    end

    def tat_data(tat_reports)
      max_columns = tat_reports.max_by { |hash| hash.size }&.keys
      {meta: {max_columns: max_columns}, data: tat_reports}
    end
  
end