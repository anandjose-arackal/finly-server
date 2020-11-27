class Docs::AuditTrails::Drawer < Drawer::API

  model AuditTrail
  find_by_key :transaction_id
  policy true
  policy_action :index

  block block_key: :beneficiary, label: "Event", icon: "icon_url" do
    label_value value: :item_type, format: 'standard', label: "Document Type"
    label_value value: :item_id, format: 'standard', label: "Document ID"
    label_value value: "{{record.created_by.name}}", format: 'standard', label: "Actor"
    label_value value: :user_ip, format: 'standard', label: "IP Address"
    label_value value: :created_at, format: 'standard', label: "Date Time"
  end


  #@overload  build
  def self.build(user, record)
    record_exposure = record.first.to_exposure
    map = []
    self.blocks.each do |block_key, block|
      data_provider = data_provider(user, record, record_exposure)
      map << block.build(data_provider, user, record, record_exposure)
    end

    record.each_with_index do |item, k|
      item_exposure = item.to_exposure
      proc = Proc.new{
        item_exposure.changes.each do |key,value|
        change value: value, label: key.to_s;
        end }
      dynamic_block = block(block_key: "change_block_#{k}".to_sym , label: item_exposure.item_type_label, icon: "icon_url", &proc)
      data_provider = data_provider(user, item, item_exposure)
      map << dynamic_block.build(data_provider, user, item, item_exposure)
    end
    {blocks: map,update_path:self.update_path}
  end

end