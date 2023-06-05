module ApprovalTatReports::TatHelper
    
    def export_report(documents,route,optimize_tat_report)
      tat_reports = []
      case route.upcase
      when "INVOICES"
        return invoice_tat_report(documents, tat_reports, optimize_tat_report)
      when "PURCHASE_REQUESTS"
        return purchase_request_tat_report(documents, tat_reports, optimize_tat_report)
      when "PURCHASE_ORDERS"
        return purchase_order_tat_report(documents, tat_reports, optimize_tat_report)
      when "PAYMENT_TICKETS"
        return bank_payment_request_tat_report(documents, tat_reports, optimize_tat_report)
      when "AGREEMENTS"
        return payment_agreement_tat_report(documents, tat_reports, optimize_tat_report)
      when "UTILITY_SUBSCRIPTIONS"
        return bbps_biller_subscriptions_tat_report(documents, tat_reports, optimize_tat_report)
      when "VENDORS"
        return vendors_tat_report(documents, tat_reports, optimize_tat_report)
      end
    end

    def invoice_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [ {payments: {purchase_order: [:bank_payment_request]}} ]
      filtered_documents = documents&.not_open
      filtered_documents = filtered_documents&.includes(required_includes) if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        invoice_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names  = (invoice_reviewal_chain&.present? && document&.processing?) ? get_pending_approval_level_approver(document, invoice_reviewal_chain) : ["",""]

        data[:invoice_id] = document&.invoice_id
        data[:business_name] = document&.vendor&.business_name
        data[:trade_name] = document&.vendor&.trade_name
        data[:policy_name] = document&.policy&.name
        data[:invoice_number] = document&.invoice_number
        data[:invoice_date] = document&.date&.to_date&.strftime("%d-%m-%Y")
        data[:invoice_status] = document&.status&.name
        data[:invoice_pending_for_approval_at_level] = pending_approval_level
        data[:invoice_pending_with_approver] = pending_approver_names
        data[:invoice_amount] = document&.forms_enabled ? document&.invoice_net_total_amount : document&.net_amount
        data[:po_number] = (document&.po_number ||= "")
        data[:invoice_submitted_by] = "#{document&.created_by&.first_name} #{document&.created_by&.last_name}"
        data[:invoice_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        data[:interval_between_invoice_date_to_invoice_submission] = (document&.date&.present? && document&.submitted_at&.present?) ? (document&.date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        
        assign_reviewers_data(document, data, invoice_reviewal_chain) if invoice_reviewal_chain.present?
        
        payment = document&.payments&.order(created_at: :desc)&.first
        invoice_payment_ticket = payment&.payment_order&.bank_payment_request
        pt_reviewal_chain = invoice_payment_ticket&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : invoice_payment_ticket&.get_reviewal_chain
        pending_approval_level, pending_approver_names  = pt_reviewal_chain&.present? ? get_pending_approval_level_approver(document, pt_reviewal_chain) : ["",""]

        data[:payment_ticket_created_by] = "#{invoice_payment_ticket&.created_by&.first_name} #{invoice_payment_ticket&.created_by&.last_name}"
        payment_ticket_created_at = invoice_payment_ticket&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        data[:payment_ticket_created_date] = payment_ticket_created_at ? payment_ticket_created_at : ""
        data[:payment_ticket_status] = invoice_payment_ticket&.status&.name
        data[:payment_ticket_pending_for_approval_at_level] = pending_approval_level
        data[:payment_ticket_pending_with_approver] = pending_approver_names
        data[:interval_between_approval_to_payment_ticket_creation] = (invoice_payment_ticket&.approved_at && payment_ticket_created_at) ? ( invoice_payment_ticket&.approved_at&.to_date - payment_ticket_created_at&.to_date )&.abs : ""
        
        if pt_reviewal_chain.present?
          last_level_approval_date = payment_ticket_created_at
          current_level_approval_date = ""
          pt_last_level = pt_reviewal_chain&.last[:level_number]
          pt_approval_levels = (1..pt_last_level&.to_i).to_a
          pt_actual_approval_levels = pt_reviewal_chain&.map { |review_chain|  review_chain[:level_number]}
          
          pt_approval_levels&.each do |each_level|
            if pt_actual_approval_levels.include?(each_level)
              selected_level_reviewer = pt_reviewal_chain&.select { |review_chain| review_chain[:level_number]&.to_s == each_level&.to_s }&.first
              data["level_#{each_level}_payment_ticket_approver_name"] =  selected_level_reviewer[:action_taken] ? fetch_approver_name(selected_level_reviewer) : ""
              current_level_approval_date = selected_level_reviewer[:action_taken] ? selected_level_reviewer[:action_taken_at]&.to_date&.strftime("%d-%m-%Y") : ""
              data["level_#{each_level}_payment_ticket_approval_date"] = current_level_approval_date
              data["level_#{each_level}_payment_ticket_interval_from_last_level"] = ((current_level_approval_date&.present? && last_level_approval_date&.present?) ? (current_level_approval_date&.to_date - last_level_approval_date&.to_date)&.abs : "")
              last_level_approval_date = current_level_approval_date
            else
              data["level_#{each_level}_approver_name"] = ""
              data["level_#{each_level}_approval_date"]  = ""
              data["level_#{each_level}_interval_from_last_level"] = ""
            end
          end
        end
        ageing_days = ""
        if document&.paid? || document&.partially_paid?
          payment_date = get_payment_date(invoice_payment_ticket, payment)
          ageing_days = (payment_date&.present? && document&.date&.to_date) ? (payment_date&.to_date - document&.date&.to_date)&.abs : ""
        end
        data["invoice_ageing"] = ageing_days
        tat_reports.push(data)
      end
      return tat_data(tat_reports)
    end

    def purchase_request_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [:policy, :status]
      filtered_documents = documents&.not_draft
      filtered_documents = filtered_documents&.includes(required_includes) if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        pr_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names = (pr_reviewal_chain&.present? && document&.awaiting_approval?) ? get_pending_approval_level_approver(document, pr_reviewal_chain) : ["",""]

        data[:purchase_request_no] = document&.order_number
        data[:policy_name] = document&.policy&.name
        data[:purchase_request_status] = document&.status&.name
        data[:pending_for_approval_at_level] = pending_approval_level
        data[:pending_with_approver] = pending_approver_names
        data[:pr_amount] = document&.total_amount&.value
        data[:pr_submitted_by] = "#{document&.creator&.first_name} #{document&.creator&.last_name}"
        data[:pr_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = assign_reviewers_data(document, data, pr_reviewal_chain) if pr_reviewal_chain&.present?

        data[:pr_ageing] = (document&.submitted_at && last_level_approval_date&.present?) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def purchase_order_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [:policy, :status]
      filtered_documents = documents&.not_open
      filtered_documents = not_open_documents&.includes(required_includes) if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        po_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names = (po_reviewal_chain&.present? && document&.processing?) ? get_pending_approval_level_approver(document, po_reviewal_chain) : ["",""]

        data[:purchase_order_no] = document&.po_number
        data[:vendor_name] = document&.vendor&.business_name
        data[:policy_name] = document&.policy&.name
        data[:po_status] = document&.status&.name
        data[:pending_for_approval_at_level] = pending_approval_level
        data[:pending_with_approver] = pending_approver_names
        data[:po_amount] = document&.total_after_tax&.value
        data[:po_submitted_by] = "#{document&.created_by&.first_name} #{document&.created_by&.last_name}"
        data[:po_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = assign_reviewers_data(document, data, po_reviewal_chain) if po_reviewal_chain&.present?

        data[:po_ageing] = (document&.submitted_at && last_level_approval_date&.present?) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def bank_payment_request_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [:status]
      filtered_documents = documents&.not_open
      filtered_documents = filtered_documents&.includes(required_includes) if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        bpr_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names = (bpr_reviewal_chain&.present? && document&.processing?) ? get_pending_approval_level_approver(document, bpr_reviewal_chain) : ["",""]
        
        bpr_payment_order = document&.payment_order
        bpr_payment_order_status = bpr_payment_order&.payment_order_status
   
        data[:payment_ticket_id] = document&.id
        data[:payment_ticket_created_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:payment_ticket_created_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
        data[:payment_ticket_status] = (bpr_payment_order_status&.id == PaymentOrderStatus.id_for(:failed)) ? bpr_payment_order_status&.name : document&.status&.name
        data[:pending_for_approval_at_level] = pending_approval_level
        data[:pending_with_approver] = pending_approver_names

        last_level_approval_date = assign_reviewers_data(document, data, bpr_reviewal_chain) if bpr_reviewal_chain&.present?
        ageing_days = ""
        if bpr_payment_order&.completed? || bpr_payment_order&.partially_completed?
          payment_date = get_payment_date(document)
          ageing_days = ( payment_date&.present? && document&.submitted_at) ? ( payment_date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        end
        data[:payment_ageing] = ageing_days
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def payment_agreement_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [:policy, :status]
      filtered_documents = documents&.not_draft
      filtered_documents = filtered_documents&.includes(required_includes)  if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        pa_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names = (pa_reviewal_chain&.present? &&  document&.awaiting_approval?) ? get_pending_approval_level_approver(document, pa_reviewal_chain) : ["",""]

        data[:agreement_no] = document&.order_number
        data[:agreement_policy_name] = document&.policy&.name
        data[:agreement_status] = document&.status&.name
        data[:pending_for_approval_at_level] = pending_approval_level
        data[:pending_with_approver] = pending_approver_names
        data[:agrement_amount] = document&.total_amount&.value
        data[:agreement_submitted_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:agreement_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = assign_reviewers_data(document, data, pa_reviewal_chain) if pa_reviewal_chain&.present?

        data[:agrement_ageing] = (document&.submitted_at && last_level_approval_date&.present?) ? ( last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def bbps_biller_subscriptions_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [:policy, :status]
      filtered_documents = documents&.where&.not(status_id: BbpsBillerSubscriptionStatus.id_for(:draft))
      filtered_documents = filtered_documents&.includes(required_includes) if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        bbps_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names  = (bbps_reviewal_chain&.present? && document&.awaiting_approval?) ? get_pending_approval_level_approver(document, bbps_reviewal_chain) : ["",""]

        data[:utility_id] = document&.sequence_id
        data[:vendor_name] = document&.biller&.biller_name
        data[:policy_name] = document&.policy&.name
        data[:status] = document&.status&.name
        data[:pending_for_approval_at_level] = pending_approval_level
        data[:pending_with_approver] = pending_approver_names
        data[:utility_master_submitted_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:utility_master_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")   

        last_level_approval_date = assign_reviewers_data(document, data, bbps_reviewal_chain) if bbps_reviewal_chain&.present?

        data[:utility_ageing ] = (document&.submitted_at && last_level_approval_date&.present?) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def vendors_tat_report(documents, tat_reports, optimize_tat_report)
      required_includes = [:policy, :status]
      filtered_documents = documents&.non_draft
      filtered_documents = filtered_documents&.includes(required_includes) if optimize_tat_report

      filtered_documents&.find_each do |document|
        data = {}
        vendor_reviewal_chain = document&.dlrms&.any? { |dlrm| dlrm.level.nil? } ? "" : document&.get_reviewal_chain
        pending_approval_level, pending_approver_names  = (vendor_reviewal_chain&.present? && document&.awaiting_approval?) ? get_pending_approval_level_approver(document, vendor_reviewal_chain) : ["",""]
        
        data[:vendor_number] = document&.vendor_id
        data[:vendor_legal_name] = document&.business_name
        data[:vendor_trade_name] = document&.trade_name
        data[:policy_name] = document&.policy&.name
        data[:status] = document&.status&.name
        data[:pending_for_approval_at_level] = pending_approval_level
        data[:pending_with_approver] = pending_approver_names
        data[:vendor_submitted_by] = "#{document&.created_by&.first_name} #{document.created_by&.last_name}"
        data[:venodr_submitted_date] = document&.submitted_at&.to_date&.strftime("%d-%m-%Y") 

        last_level_approval_date = assign_reviewers_data(document, data, vendor_reviewal_chain) if vendor_reviewal_chain&.present?

        data[:vendor_ageing ] = (document&.submitted_at && last_level_approval_date&.present?) ? (last_level_approval_date&.to_date - document&.submitted_at&.to_date)&.abs : ""
        data[:vendor_last_modified] = document&.updated_at&.strftime("%d-%m-%Y %T")
        tat_reports.push(data.with_indifferent_access)
      end
      return tat_data(tat_reports)
    end

    def fetch_approver_name(review_chain)
      reviewer = review_chain&.dig(:reviewers)&.select{ |each_reviewer| each_reviewer.dig(:action_taken)}
        
      if reviewer&.present?
        return reviewer&.first&.dig(:name)
      elsif review_chain&.dig(:taken_control_by,:name)&.present?
        return review_chain&.dig(:taken_control_by,:name)
      elsif review_chain&.dig(:forwarded_to,:name)&.present?
        return review_chain&.dig(:forwarded_to,:name)
      end

    end

    def get_payment_date(bank_payment_request, payment = nil)
      bank_payment_request_comment_action = BankPaymentRequestCommentAction.id_for(:mark_as_credited)
      payment_date = bank_payment_request&.comments&.find { |each_comment| each_comment.action_id == bank_payment_request_comment_action }&.updated_at
      if payment_date&.present?
        return payment_date
      else
        if payment
          return payment&.processed_at
        else
          payments = bank_payment_request&.payment_order&.payments
          return payments&.order(processed_at: :desc)&.first&.processed_at
        end
      end
    end

    def assign_reviewers_data(document, data, reviewal_chain)
      last_level_approval_date = document&.submitted_at&.to_date&.strftime("%d-%m-%Y")
      approval_levels = (1..reviewal_chain&.last[:level_number]&.to_i).to_a
      actual_approval_levels =  reviewal_chain&.map { |review_chain|  review_chain[:level_number]}

      approval_levels&.each do |each_level|
        if actual_approval_levels.include?(each_level)
          selected_level_reviewer = reviewal_chain&.select { |review_chain| review_chain[:level_number].to_s == each_level.to_s }&.first
          data["level_#{each_level}_approver_name"] = selected_level_reviewer[:action_taken] ? fetch_approver_name(selected_level_reviewer) : ""
          current_level_approval_date = (selected_level_reviewer[:action_taken] ? selected_level_reviewer[:action_taken_at] : "")
          data["level_#{each_level}_approval_date"]  = current_level_approval_date&.to_date&.strftime("%d-%m-%Y")
          data["level_#{each_level}_interval_from_last_level"] = ((current_level_approval_date&.present? && last_level_approval_date&.present?) ? (current_level_approval_date&.to_date - last_level_approval_date&.to_date)&.abs : "")
          last_level_approval_date = current_level_approval_date
          selected_level_reviewer = ""
        else
          data["level_#{each_level}_approver_name"] = ""
          data["level_#{each_level}_approval_date"] = ""
          data["level_#{each_level}_interval_from_last_level"] = ""
        end
      end
      last_level_approval_date
    end

    def tat_data(tat_reports)
      max_columns = tat_reports.max_by { |hash| hash.size }&.keys
      {meta: {max_columns: max_columns}, data: tat_reports}
    end

    def get_pending_approval_level_approver(document, reviewal_chain)
      pending_approver_names = ""
      not_approved_level = reviewal_chain&.find { |each_level| !each_level.dig(:action_taken)}
      if not_approved_level&.dig(:forwarded_to)&.present?
        pending_approver_names = not_approved_level&.dig(:forwarded_to,:name)
      elsif 
        pending_approver_names = not_approved_level&.dig(:reviewers)&.map { |reviewer| reviewer[:name] }&.join(',')
      end
      [not_approved_level&.dig(:level_number), pending_approver_names]
    end
  
end
