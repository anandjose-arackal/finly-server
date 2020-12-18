# Vendor Submit will first create the vendor & Then submit it
class Vendors::CreateAndSubmit < Vendors::Base

  class Vendors::CreateAndSubmit::SubmitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendor

    def init
      self.vendor = params[:vendor]
    end
  end

  def init
    # Create Vendor
    op_create = Vendors::Create.(user, params)

    if op_create.success?
      self.vendor = op_create.vendor
    else
      if vendor.present?
        self.vendor.really_destroy!
      end
      add_message :error, op_create.messages[:error]
      return
    end
    # id = params[:vendor_id] || params[:yes_bank_vendor] || params[:id] 
    # self.vendor = Vendors::Show.(user, params).vendors.with_id(id).first rescue nil
  end

  def process
    if self.vendor.policy_id.present?
      self.vendor.paper_trail_event = "Submit"
      params[:document] = self.vendor
      params[:aasm_event] = 'submit'

      op = WorkflowManager::Base.(user, params)
      unless op.success?
        # Hard delete the record as this operation is only called on vendor creation
        if self.vendor.present? 
          self.vendor.really_destroy!
        end
        add_message :error, op.messages[:error]
        return
      end

      self.workflow_output = op.workflow_output
    else
      add_message :error, "Policy not found"
      return
      # self.vendor.update(status_id: VendorStatus.id_for(:auto_approved))
    end
  end

  def post_process
    if vendor.status_id == VendorStatus.id_for(:auto_approved)
      add_message :success, "Vendor Added & Approved"
    else
      add_message :success, "Vendor Submitted for Approval"
    end
    Event::EVendors::Submit.(user, document: self.vendor)
  end

  def success
    params[:vendor] = self.vendor
    Vendors::CreateAndSubmit::SubmitPresenter.new(user, params, messages)
  end
end