class Bbps::BillsController < BaseControllers::WebBase
  layout :resolve_layout

  set_tokens_in_header :download_receipt

  def edit_config
    endpoint Docs::UtilityBills::Bills::Configs::Edit
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    endpoint Docs::UtilityBills::Bills::Configs::Filters
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint Docs::UtilityBills::Bills::Ops::Update
    respond_to do |format|
      format.json {}
    end
  end

  def update_and_submit
    params[:id] = params[:id] || params[:_id]
    endpoint Docs::UtilityBills::Bills::Ops::UpdateAndSubmit
  end

  def index
    endpoint Docs::UtilityBills::Bills::Ops::Index
    respond_to do |format|
      format.json {}
    end
  end

  def payable_bills
    params[:filter_status] = 'payables'
    endpoint Docs::UtilityBills::Bills::Ops::Index
    respond_to do |format|
      format.json {render :index}
    end
  end

  def show
    endpoint Docs::UtilityBills::Bills::Ops::Show
    respond_to do |format|
      format.json {}
    end
  end

  def review
    params[:aasm_event] = params[:type]
    endpoint Docs::UtilityBills::Bills::Ops::Review
    respond_to do |format|
      format.json {}
    end
  end

  def bill_validate
    endpoint Docs::UtilityBills::Bills::Ops::BillValidate
  end

  def actions_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

  def destroy
    endpoint Docs::UtilityBills::Bills::Ops::Destroy
    respond_to do |format|
      format.json {}
    end
  end

  def download_receipt
    current_user
    params[:id] = params[:id] || params[:bill_id]
    @op = Docs::UtilityBills::Bills::Ops::Show.(params: params, current_user: current_user)

    # unless @op.success? && BbpsBillStatus.ids_for(:paid, :failed).include?(@op['model'].status_id)
    #   controller.render json: {success: false, messages: result.messages.as_json}, status: 404
    # end
    @bill = @op['model']

    respond_to do |format|
      format.pdf {
        render pdf: "bill-#{@bill.sequence_id}-#{@bill.subscription.name}-#{@bill.bill_period}",
               layout: "pdf/paginated_bootstrap.html.erb",
               template: "export/bbps_bill",
               print_media_type: true,
               margin: {:bottom => 12},
               dpi: 650
        # header: { left: '[page] of [topage]' },
        # header: { center: @result.purchase_order&.po_number },
        # footer: { html: { template: 'layouts/partials/_po_footer.html.erb' }}
        # header: { html: { template: 'export/header_pagination.html.erb' }}
      }
    end
  end

  private

  def resolve_layout
    case action_name
    when 'actions_config'
      'application'
    else
      'trailblazers'
    end
  end
end