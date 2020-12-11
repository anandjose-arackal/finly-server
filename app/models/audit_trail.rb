class AuditTrail < PaperTrail::Version
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include Ransacker
  include SoftDeletable

  default_scope {order(created_at: :desc)}
  belongs_to :created_by, optional: true, class_name: "User"
  belongs_to :item, optional: true, polymorphic: true

  scope :with_user_transaction_id, -> (ref_id) { where user_transaction_id: ref_id }

  def changes_less
    self.get_change_statement(less: true).map{|change| "#{change&.first&.to_s&.titlecase} Changed #{(change&.last)&.join(' -> ')}"}&.join(' , ')
  end

  def get_document_number
    case self.item_type
    when "PurchaseOrder"
      self.document_number = self.item.po_number
    when "PurchaseOrderItem"
      self.document_number = self.item.purchase_order.po_number
    when  "Invoice"
      self.document_number = self.invoice_id
    when  "InvoiceLineItem"
      self.document_number = self.item.invoice.invoice_id
    when "PurchaseRequest"
      self.document_number = self.item.order_number
    when "PurchaseRequestItem"
      self.document_number = self.item.purchase_request.order_number
    when "YesBankVendor"
      self.document_number = self.item.vendor_id
    when  "BankAccount"
      self.document_number = self.item.account_owner.try(:vendor_id)
    when "GstinLocation"
      self.document_number = self.item.vendor.try(:vendor_id)
    end
    self.document_number
  end

  def get_change_statement(less=false)
    return {} if self.object_changes.nil?
    if less
     changes = self.changeset&.last(2) rescue {}
    else
      changes = self.changeset rescue {}
    end
    changes = convert_object_changes_to_hash(changes)
    sanitize_data(changes)
  end

  private

  def sanitize_data(changes)
    return changes if changes.count < 3
    changes = changes.reject{|k,v| v.first.to_s == v.last.to_s}
  end

  def convert_object_changes_to_hash(changes)
    all_reflections = get_all_reflections
    klass = self.item_type.constantize
    hash ={}
    changes.each do |k,v|
      if all_reflections.has_key? k
        hash.merge!(get_value_change(all_reflections[k], v))
      elsif [:datetime,:date].include? klass.columns_hash[k.to_s]&.type
        date_change = v.map{ |date_string| date_string&.strftime("%d/%m/%Y %H:%M:%S") rescue ""}
        hash.merge!({k.to_s&.titlecase => date_change})
      elsif [:boolean].include? klass.columns_hash[k.to_s]&.type
        boolean_change = v.map{ |boolean_value|  boolean_value == "true" ? 'Yes' : 'No' rescue ""}
        hash.merge!({k.to_s&.titlecase => boolean_change})
      else
        hash.merge!({k.to_s&.titlecase => v})
      end
    end
    hash
  end

  def get_all_reflections
    klass = self.item_type.constantize
    hash = {}
    klass.reflect_on_all_associations(:belongs_to).map{|reflect| hash[reflect.foreign_key] ={name: reflect.name ,klass: reflect.klass}}
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
      value = klass.unscoped.find_by_id(identifier)&.value&.round(2)
    when  "ReviewalLevel"
      value = klass.unscoped.find_by_id(identifier)&.level_number
    when  "GstinLocation"
      value = klass.unscoped.find_by_id(identifier)&.location
    when  "YesBanVendor"
      value = klass.unscoped.find_by_id(identifier)&.business_name
    when "BankAccount"
      value = klass.unscoped.find_by_id(identifier)&.name
    else
      value = klass.unscoped.find_by_id(identifier)&.try(:name)&.titlecase
      if value.nil?
        value = klass.unscoped.find_by_id(identifier)&.try(:description)
      end
    end
    value
  end

  def self.parent_document_types
    %w( PurchaseRequest
        PurchaseOrder
        Invoice
        YesBankVendor
      )
  end

  def self.generate_transaction_id
    date = DateTime.now
    prefix = DateTime.now.to_i
    ref_id = Generator.random_number(8)
    while !self.validate_transaction_id("#{prefix}#{ref_id}")
      ref_id = Generator.random_number(8)
    end
    "#{prefix}#{ref_id}"
  end

  def self.validate_transaction_id(reference_id)
    (not AuditTrail.with_user_transaction_id(reference_id).present?)
  end

end