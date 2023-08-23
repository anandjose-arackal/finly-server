module UtrEmailable
  extend ActiveSupport::Concern

  included do
    attr_accessor :old_utr_present, :old_utr
    before_save do
      self.old_utr ||= self.utr_was.to_s
    end

    after_commit :send_email_on_utr_update

    private
    
    def send_email_on_utr_update
      if self.utr.present? and self.old_utr != self.utr and self.send_email_if_valid?
        BackgroundJobs::UtrUpdateEmail::SendInvoiceEmailOnUtrUpdateBackground.perform_async(self.id)
      end
    end

    def send_email_if_valid?
      self.invoice.present? and
      self.invoice.created_by.present? and
      SendInvoiceEmailOnUtrUpdateToggle.new(self.invoice.created_by).enabled?
      # `SendInvoiceEmailOnUtrUpdateToggle` should be enabled since we are trying to send emails after `bulk UTR upload` action
    end

  end
end