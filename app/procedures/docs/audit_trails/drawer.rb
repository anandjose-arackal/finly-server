class Docs::AuditTrails::Drawer < Drawer::API

  model AuditTrail
  find_by_key :user_transaction_id
  policy true
  policy_action :index

  block block_key: :beneficiary, label: "Event", icon: "icon_url" do
    label_value value: :parent_document_type, format: 'standard', label: "Document Type"
    label_value value: :document_number, format: 'standard', label: "Document ID"
    label_value value: "{{record.created_by.name}}", format: 'standard', label: "Actor"
    label_value value: :user_ip, format: 'standard', label: "IP Address"
    label_value value: "{{record.created_at | date: '%d/%m/%Y %H:%M:%S' }}", format: 'standard', label: "Date Time"
  end


  #@overload  build
  def self.build(user, record)
    record_exposure = record.first.to_exposure
    map = []
    self.blocks.each do |block_key, block|
      data_provider = data_provider(user, record.first, record_exposure)
      map << block.build(data_provider, user, record, record_exposure)
      break
    end
    record.group_by(&:item_id).each do | k,item_group|
      dup_exposure =item_group.first.to_exposure
      hash ={}
      item_group.each do |item|
        item_exposure = item.to_exposure
        item_exposure.changes.each do |key,value|
          hash[key] ={item: item, value: value}
        end
      end

      proc = Proc.new{
        hash.each do |key,value_hash|
        change value: value_hash[:value], label: key.to_s;
        end }
      dynamic_block = block(block_key: "change_block_#{k}".to_sym , label: dup_exposure.item_type_label, icon: "icon_url", &proc)
      data_provider = data_provider(user, item_group.first, dup_exposure)
      map << dynamic_block.build(data_provider, user, item_group.first, dup_exposure)
    end
    {blocks: map, update_path:self.update_path}
  end

end