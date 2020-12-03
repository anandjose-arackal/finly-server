class AuditTrail < PaperTrail::Version
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include Ransacker
  include SoftDeletable

  default_scope {order(created_at: :desc)}
  before_save :set_document_details
  belongs_to :created_by, optional: true, class_name: "User"

  def set_document_details
    klass = self.item_type.constantize
    object = klass.find self.item_id
    case self.item_type
    when "PurchaseOrder"
      self.document_number = object.po_number
    when "PurchaseOrderItem"
      oself.document_number = bject.purchase_order.po_number
    when  "Invoice"
      self.document_number = object.invoice_id
    when  "InvoiceLineItem"
      self.document_number = object.invoice.invoice_id
    when "PurchaseRequest"
      self.document_number = object.order_number
    when "PurchaseRequestItem"
      self.document_number = object.purchase_request.order_number
    when "YesBankVendor"
      self.document_number = object.vendor_id
    when  "BankAccount"
      self.document_number = object.account_owner.try(:vendor_id)
    when "GstinLocation"
      self.document_number = object.vendor.try(:vendor_id)
    end
  end

  def changes_less
    self.get_change_statement(less: true).map{|change| "#{change&.first&.to_s&.titlecase} Changed #{(change&.last)&.join(' -> ')}"}&.join(' , ')
  end

  def get_change_statement(less=false)
    return {} if self.object_changes.nil?
    if less
     changes = self.changeset&.first(2) rescue {}
    else
      changes = self.changeset rescue {}
    end
    all_reflections = get_all_reflections
    hash ={}
    changes.each do |k,v|
       if all_reflections.has_key? k
        hash.merge!(get_value_change(all_reflections[k], v))
      else
        hash.merge!({k.to_s&.titlecase => v})
      end
    end
    hash
  end

  private
  def get_all_reflections
    klass = self.item_type.constantize
    hash = {}
    klass.reflect_on_all_associations(:belongs_to).map{|reflect| hash[reflect.foreign_key] ={name:reflect.name ,klass:reflect.klass}}
    hash.with_indifferent_access
  end

  def get_value_change(reflection, changes)
    changed_from = get_value(reflection[:klass], changes&.first)
    changed_to = get_value(reflection[:klass], changes&.last)
    {reflection[:name]&.to_s&.titlecase => [changed_from, changed_to]}
  end

  def get_value(klass, identifier)
    return "" if identifier.nil?
    case klass.to_s
    when "Amount"
      value = klass.find_by_id(identifier)&.value
    when  "ReviewalLevel"
      value = klass.find_by_id(identifier)&.level_number
    else
      value = klass.find_by_id(identifier)&.try(:name)&.titlecase
    end
    value
  end

end