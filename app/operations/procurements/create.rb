class Procurements::Create < Procurements::Base
  attr_accessor :procurement, :procurement_params

  def init
    self.procurement_params = procurement_parameters
  end

  def validate
    if params[:document_type].blank?
      add_message :error, 'Please provide document type to create procurement'
      return
    end

    document_types = %w( purchase_order invoice )
    unless document_types.include?(params[:document_type])
      add_message :error, 'Invalid document type provided'
    end


  end

  def process
    self.procurement = user.procurements.build(procurement_params)
    self.procurement.company = user.company
    self.procurement.procurement_type = params[:document_type]

    self.procurement.procurement_status_id = ProcurementStatus.id_for(:draft)

    unless self.procurement.save
      add_message :error, self.procurement.errors.full_messages
      return
    end

    params[:procurement_id] = self.procurement.id
    case params[:document_type]
      when 'purchase_order'
        op = Procurements::PurchaseOrders::Create.(user, params)
      when 'invoice', 'proforma_invoice'
        # add_message :error, 'Invalid document type provided'
        op = Procurements::Invoices::Create.(user, params)
        # do nothing!
        # tax invoice / proforma invoice will be created
      else
        add_message :error, 'Invalid document type provided'
        return

    end
    if op.success?
      add_message :success, 'Successfully created new procurement'
    else
      add_message :error, op.messages[:error]
    end
  end

  def success
    params[:procurement] = self.procurement
    Procurements::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurement, :invoices, :purchase_order

    def init
      self.procurement = params[:procurement]
      self.invoices = self.procurement.invoices
      self.purchase_order = self.procurement.purchase_order
    end
  end

  private

  def procurement_parameters
    params.require(:procurement).permit(:name, :note, :vendor_id)
  end
end