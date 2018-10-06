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

  def approve
    @result = Procurements::PurchaseOrders::Approve.(current_user, params)
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

  def download
    @result = Procurements::PurchaseOrders::Show.(current_user, params)
    @purchase_order = @result.purchase_order
    @company = @purchase_order.company
    respond_to do |format|
      format.pdf {
          render pdf: "PO-#{@result.purchase_order.po_number}",
                 layout: "pdf.html.erb",
                 print_media_type: true,
                 margin: { :bottom => 5 },
                 footer: { html: { template: 'invoice_mailer/invoice_footer.html.erb' }}
                 # header: { html: { template: 'export/header_pagination.html.erb' }}
      }
      format.html {
        render pdf: "PO-#{@result.purchase_order.po_number}",
                 layout: "pdf.html.erb",
                 print_media_type: true,
                 margin: { :bottom => 5 },
                 footer: { html: { template: 'invoice_mailer/invoice_footer.html.erb' }}
                 # header: { html: { template: 'export/header_pagination.html.erb' }}
      }
    end
  end

  # Templates
  def template_create
    @result = Procurements::PurchaseOrders::Templates::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
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

end