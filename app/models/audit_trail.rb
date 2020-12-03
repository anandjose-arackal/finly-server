class AuditTrail < PaperTrail::Version
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include Ransacker
  include SoftDeletable

  default_scope {order(created_at: :desc)}
  belongs_to :created_by, optional: true, class_name: "User"


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
    convert_object_changes_to_hash(changes)
  end

  private
  def convert_object_changes_to_hash(changes)
    all_reflections = get_all_reflections
    klass = self.item_type.constantize
    hash ={}
    changes.each do |k,v|
      if all_reflections.has_key? k
        hash.merge!(get_value_change(all_reflections[k], v))
      elsif [:datetime,:date].include? klass.columns_hash[k.to_s].type
        date_change = v.map{ |date_string| Date.parse(date_string)&.strftime("%d/%m/%Y %H:%M:%S") rescue ""}
        hash.merge!({k.to_s&.titlecase => date_change})
      else
        hash.merge!({k.to_s&.titlecase => v})
      end
    end
    hash
  end

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
    when  "GstinLocation"
      value = klass.find_by_id(identifier)&.location
    when  "YesBanVendor"
      value = klass.find_by_id(identifier)&.business_name
    when "BankAccount"
      value = klass.find_by_id(identifier)&.name
    else
      value = klass.find_by_id(identifier)&.try(:name)&.titlecase
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

end