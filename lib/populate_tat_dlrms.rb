class PopulateTatDlrms
  def self.run
    result = {
        "PurchaseOrder": {open_status_ids: PurchaseOrderStatus.ids_for(:open, :draft, :rejected, :retracted)},
        "Report": {open_status_ids: ReportStatus.ids_for(:open, :rejected, :retracted)},
        "MoneyRequest": {open_status_ids: MoneyRequestStatus.ids_for(:open, :rejected, :retracted)},
        "BankPaymentRequest": {open_status_ids: BankPaymentRequestStatus.ids_for(:open, :rejected, :retracted)},
        "Invoice": {open_status_ids: InwardInvoiceStatus.ids_for(:open, :rejected, :retracted)},
        "TravelRequest": {open_status_ids: TravelRequestStatus.ids_for(:open, :rejected, :retracted)},
        "PurchaseRequest": {open_status_ids: PurchaseRequestStatus.ids_for(:draft, :rejected, :retracted)},
        "YesBankVendor": {open_status_ids: VendorStatus.ids_for(:draft, :rejected, :retracted)},
        "PaymentAgreement": {open_status_ids: PaymentAgreementStatus.ids_for(:draft, :rejected, :retracted)},
        "BbpsBillerSubscription": {open_status_ids: BbpsBillerSubscriptionStatus.ids_for(:draft, :rejected, :retracted)},
        "BbpsBill": {open_status_ids: BbpsBillStatus.ids_for(:open, :rejected, :retracted)},
        "CreditNote": {open_status_ids: CreditNoteStatus.ids_for(:draft, :rejected, :retracted)}
    }

    unless File.exists?('/home/centos/script_result/dlrm-tat.csv') || File.exists?('/home/centos/script_result/dlrm-no-submitted-at.csv')
      raise 'Log files not found'
    end

    file_result = File.open('/home/centos/script_result/dlrm-tat.csv', 'a')
    file_no_submitted_at = File.open('/home/centos/script_result/dlrm-no-submitted-at.csv', 'a')

    result.each do |document_type, hash|
      klass = document_type.to_s.constantize
      docs = klass.where.not("#{klass.document_status_attribute} in (?)", hash[:open_status_ids]).where(id: DocumentLevelReviewerMapping.select(:document_reviewer_mappable_id).where(document_reviewer_mappable_type: document_type.to_s))

      count = docs.count - 1

      docs.in_batches.each_with_index do |batch, batch_index|
        batch.each_with_index do |doc, outer_index|

          submitted_at = [doc.submitted_at, doc.trails.where(action_id: TrailAction.id_for(:submit)).reorder(:created_at).last&.created_at].compact.max

          print "  Migrating #{document_type.to_s} => #{((batch_index + 1) * 1000) + outer_index}/#{count} Documents \r"

          company_id = doc.company_id rescue ""

          unless submitted_at.present?
            file_no_submitted_at.write("#{document_type.to_s},#{doc.id},#{company_id}\n")
            next
          end

          grouped_dlrms = doc.dlrms.where.not(action_id: nil).reorder(:level_number).group_by(&:level_number)

          keys = grouped_dlrms.keys

          next if keys.empty?

          level_string = "#{document_type.to_s},#{doc.id},#{company_id}"

          grouped_dlrms.each_with_index do |(key, val), index|
            next if val.map(&:action_id).compact.blank?
            if index == 0
              action_taken_at = val.map(&:action_taken_at).compact[0] || doc.trails.with_action_id(val.map(&:action_id).compact[0]).with_action_user_id(val.map(&:action_taken_by_id).compact).reorder(:created_at).last&.created_at || val[0].updated_at

              tat = (action_taken_at - submitted_at).abs

              level_string += ",Level-#{key} - #{tat}"

              val.each {|dlrm| dlrm.update_columns(tat: tat, tat_added_by_script: true)}

            else
              prev_val = grouped_dlrms[keys[index - 1]]

              previous_action_taken_at = prev_val.map(&:action_taken_at).compact[0] || doc.trails.with_action_id(prev_val.map(&:action_id).compact[0]).with_action_user_id(prev_val.map(&:action_taken_by_id).compact).reorder(:created_at).last&.created_at || prev_val[0].updated_at

              action_taken_at = val.map(&:action_taken_at).compact[0] ||
                  doc.trails.
                      with_action_id(val.map(&:action_id).compact[0]).
                      with_action_user_id(val.map(&:action_taken_by_id).compact).reorder(:created_at).
                      last&.created_at ||
                  val[0].updated_at


              tat = (action_taken_at - previous_action_taken_at).abs

              level_string += ",Level-#{key} - #{tat}"

              val.each {|dlrm| dlrm.update_columns(tat: tat.abs, tat_added_by_script: true)}
            end
          end; nil

          level_string += "\n"

          file_result.write(level_string)

        end; nil
      end; nil
    end; nil

    file_no_submitted_at.close
    file_result.close
  end
end