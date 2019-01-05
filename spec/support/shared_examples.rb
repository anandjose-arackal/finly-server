# shared_examples_for 'a model that allows mass assignment for' do |*fields|
#   fields.each do |field|
#     it { should allow_mass_assignment_of(field) }
#   end
# end
#
# shared_examples_for 'presence of' do |property|
#   it "requires a value for #{property}" do
#     record = described_class.new
#     record.send(:"#{property}=", nil)
#     record.should_not be_valid
#     record.errors[property.to_sym].should include("can't be blank")
#   end
# end
#
# shared_examples_for 'a model with the following database columns' do |*columns|
#   columns.each do |column|
#     it do
#       name, type, options = *column
#
#       have_this_column = have_db_column(name)
#       have_this_column.of_type(type) if type.present?
#       have_this_column.with_options(options) if options.present? and options.is_a?(Hash)
#
#       should have_this_column
#     end
#   end
# end
#
# shared_examples_for 'a model with timestampable columns' do
#   it { should have_db_column(:created_at).of_type(:datetime) }
#   it { should have_db_column(:updated_at).of_type(:datetime) }
# end

RSpec.shared_examples "reviewer has access to document" do
  it "shows up in reviewer's index" do
    associated_documents_id = @document.class.reviewer_associated_items(reviewer).pluck(:id)
    expect(associated_documents_id).to include(@document.id)
  end
end

RSpec.shared_examples "reviewer does NOT have access to document" do
  it "doesn't show up in reviewer's index" do
    associated_documents_id = @document.class.reviewer_associated_items(reviewer).pluck(:id)
    expect(associated_documents_id).not_to include(@document.id)
  end
end

RSpec.shared_examples "document has moved to level" do
  debugger
  it "has controlling level as given level" do
    expect(@document.controlling_level_id).to eq(level.id)
  end
end

RSpec.shared_examples "trailed with right data" do
  it "trailed with action user & action" do
    last_trail = @document.trails.natural_order.reload.last
    expect(last_trail&.action_id).to eq(TrailAction.id_for(action))
    expect(last_trail&.action_user_id).to eq(user.id)
  end
end
