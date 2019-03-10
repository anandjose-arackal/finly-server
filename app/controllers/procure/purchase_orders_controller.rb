class Procure::PurchaseOrdersController < ApplicationController
  before_action :set_tokens_in_header, only: [:download]
  before_action -> { finly_authorize! :web }

  def index
    @result = Procurements::PurchaseOrders::Index.(current_user, params)
    respond
  end

  def show
    @result = Procurements::PurchaseOrders::Show.(current_user, params)
    respond
  end

  def create
    @result = Procurements::PurchaseOrders::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::PurchaseOrders::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::PurchaseOrders::Destroy.(current_user, params)
    respond
  end

  def send_mail
    @result = Procurements::PurchaseOrders::SendMail.(current_user, params)
    respond
  end

  def submit
    @result = Procurements::PurchaseOrders::Submit.(current_user, params)
    respond
  end

  def retract
    @result = Procurements::PurchaseOrders::Retract.(current_user, params)
    respond
  end

  def reopen
    @result = Procurements::PurchaseOrders::Reopen.(current_user, params)
    respond
  end

  def approve
    @result = Procurements::PurchaseOrders::Approve.(current_user, params)
    respond
  end

  def unapprove
    @result = Procurements::PurchaseOrders::Unapprove.(current_user, params)
    respond
  end

  def bulk_approve
    @result = Procurements::PurchaseOrders::BulkApprove.(current_user, params)
    respond
  end

  def reject
    @result = Procurements::PurchaseOrders::Reject.(current_user, params)
    respond
  end

  def close
    @result = Procurements::PurchaseOrders::Close.(current_user, params)
    respond
  end

  def remind
    @result = Procurements::PurchaseOrders::Remind.(current_user, params)
    respond
  end

  def void
    @result = Procurements::PurchaseOrders::Void.(current_user, params)
    respond
  end

  def mark_send_to_vendor
    @result = Procurements::PurchaseOrders::MarkSendToVendor.(current_user, params)
    @respond
  end

  def export_items
    @result = Procurements::PurchaseOrders::ExportItems.(current_user, params)
    respond
  end


  def download
    @result = Procurements::PurchaseOrders::Show.(current_user, params)
    @purchase_order = @result.purchase_order
    @company = @purchase_order.company

    if params[:origin] == 'download_action'
      @purchase_order.trails.create action_user: current_user,
                                     action_id: TrailAction.id_for(:downloaded),
                                     action_level: @purchase_order.trails.last.action_level
    end
    
    respond_to do |format|
      format.pdf {
          render pdf: "PO-#{@result.purchase_order.po_number}",
                 layout: "pdf/paginated_bootstrap.html.erb",
                 print_media_type: true,
                 margin: { :bottom => 5 },
                 dpi: 650,
                 # header: { left: '[page] of [topage]' },
                 footer: { html: { template: 'layouts/partials/_po_footer.html.erb' }}
                 # header: { html: { template: 'export/header_pagination.html.erb' }}
      }
      format.html {
        render pdf: "PO-#{@result.purchase_order.po_number}",
               layout: "pdf/paginated_bootstrap.html.erb",
               print_media_type: true,
               margin: { :bottom => 5 },
               footer: { html: { template: 'layouts/partials/_po_footer.html.erb' }}
        # header: { html: { template: 'export/header_pagination.html.erb' }}
      }
    end
  end

  # advance payment API 
  def create_payment
    @result = Procurements::Payments::CreateAdvance.(current_user, params)
    respond
  end

  def advance_payments
    @result = Procurements::PurchaseOrders::AdvancePayments.(current_user, params)
    respond
  end

  def create_po_revisions
    @result = Procurements::PurchaseOrders::CreatePoRevisions.(current_user, params)
    respond
  end

  # Templates
  def template_create
    @result = Procurements::PurchaseOrders::Templates::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  def template_apply
    @result = Procurements::PurchaseOrders::Templates::Apply.(current_user, params)
    respond
  end

  def template_index
    @result = Procurements::PurchaseOrders::Templates::Index.(current_user, params)
    respond
  end

  def template_show
    @result = Procurements::PurchaseOrders::Templates::Show.(current_user, params)
    respond
  end

  def template_update
    @result = Procurements::PurchaseOrders::Templates::Update.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  def template_destroy
    @result = Procurements::PurchaseOrders::Templates::Destroy.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

end