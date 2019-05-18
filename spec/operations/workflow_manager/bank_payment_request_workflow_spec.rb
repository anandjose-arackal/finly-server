require 'rails_helper'

# Employee
# Manager1, Manager2, Manager3
# Finance Manager

# Create policy
# Create Levels
# Create Workflow


# Create Expenses
# Create Report

# Pass through output with action

# Create

RSpec.xdescribe "Bank Payment Request Workflow -- " do
  before(:all) do |example|
    @company = create(:company)
    # Create Users
    @em_employee_user1 = create(:vp_initiator_user, company_id: @company.id)
    @em_reviewer_user1 = create(:vp_reviewer_user, company_id: @company.id)
    @em_reviewer_user2 = create(:vp_reviewer_user, company_id: @company.id)
    @em_reviewer_user3 = create(:vp_reviewer_user, company_id: @company.id)
    @em_finance_user1 = create(:vp_creditor_user, company_id: @company.id)
    @em_admin_user1 = create(:vp_admin_user, company_id: @company.id)

    RequestStore.store[:current_company] = @company

    # Create Policy
    @policy = create(:policy, company_id: @company.id)

    # Create User Policy Mapping
    create(:policy_user_mapping, {user_id: @em_employee_user1.id, policy_id: @policy.id})

    # Create Levels
    @level1 = create(:reviewal_level, policy_id: @policy.id, associated_entity_type: 'BankPaymentRequestProvider')
    @level2 = create(:reviewal_level, policy_id: @policy.id, associated_entity_type: 'BankPaymentRequestProvider')
    @level3 = create(:reviewal_level, policy_id: @policy.id, associated_entity_type: 'BankPaymentRequestProvider')

    # Create level reviewer mappings
    @level1.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user1.id, threshold: 0, exception: false})
    @level2.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user2.id, threshold: 0, exception: false})
    @level3.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user3.id, threshold: 0, exception: false})

    vendor_params = {vendor: {name: "test vendor 1", email: "vendor1@grr.la", mobile_number: "9876543210", authorized: true, description: "Some Description", pan: "AVWPC2314I", gst: "23AVWPC2314I8I1", state_code_id: 23, gst_registered: true, business_name: "Test Business 1", address: "Address 1", bank_accounts_attributes:[{account_number: "33846011376", ifsc: "SBIN0003578", name: "Primary Account", default_account: true, address_1: "Addr 1", address_2: "Addr 2", address_3: "Addr 3", pin_code: 560068, country: "India"}]}}

    vendor_op = BankTransfer::Vendors::Create.(@em_admin_user1, vendor_params)
    unless vendor_op.success?
      fail
    end

    bank_account = BankAccount.first

    bpr_params = {"transfer_type"=>"neft", "policy_id"=>@policy.id, "initating_account_type"=>"2", "account_owner_type"=>"2", "scheduled_at"=>"08 Jan 2019", "description"=>"TEST", "payment_order"=>{
        "0"=>{
            "account_id"=>bank_account.id, "owner_name"=>"Primary Account", "name"=>"test vendor 1", "bank_account_number"=>"33846011376", "ifsc"=>"SBIN0003578", "invoice_number"=>"", "invoice_date"=>"", "due_date"=>"", "category_id"=>"", "note"=>"", "cost_center_id"=>"", "department_id"=>"", "original_amount"=>"500", "currency_id"=>"1", "discount"=>"0", "discount_amount"=>"0", "tax"=>"0", "tax_amount"=>"0", "tds_slab_id"=>"", "tds_amount"=>"0", "advance_amount"=>"0", "freight"=>"0.00", "roundoff_amount"=>"0.00"}}, "view"=>"initiator"}

    document_op = BankTransfer::PaymentRequest::Create.(@em_employee_user1, bpr_params)
    if document_op.success?
      @document = BankPaymentRequest.first # Change this, make operation return document instead
    else
      p "Bank Payment Request Workflow", document_op.messages[:error]
    end
  end

  describe "CREATE -- " do
    # skip unless @document.persisted?
    before(:all) do |example|
      @document.reload
    end
    it "has created document level reviewer mapping" do
      expect(@document.document_level_reviewer_mappings.count).to eq(3)
    end
  end

  describe "SUBMIT -- " do
    before(:all) do |example|
      op = BankTransfer::PaymentRequest::Review::Submit.(@em_employee_user1, {id: @document.id})
      @document.reload
      if op.failure?
        p "SUBMIT", op.messages[:error]
        skip
      end
    end

    describe "trail, level -- " do

      let(:user) {@em_employee_user1}
      let(:level) {@level1}
      let(:action) {:submit}
      let(:reviewer) {@em_reviewer_user1}
      it_should_behave_like "trailed with right data"
      it_should_behave_like "document has moved to level"
      it_should_behave_like "reviewer has access to document"
    end

    describe "2nd level reviewer doesn't have access to document" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer does NOT have access to document"
    end


    # it "'s reviewer is set to level 1's reviewer" do
    #   expect(@document.get_reviewers.pluck(:id)).to include(*@level1.reviewers.pluck(:id))
    # end
    #
    #
    # it "doensn't shows up 2nd level reviewers's index yet" do
    #   associated_documents_id = Report.reviewer_associated_items(@em_reviewer_user2).pluck(:id)
    #   expect(associated_documents_id).not_to include(@document.id)
    # end
  end

  describe "APPROVE 1ST LEVEL -- " do
    before(:all) do |example|
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      op = BankTransfer::PaymentRequest::Review::Approve.(@em_reviewer_user1, {id: @document.id})

      if op.failure?
        p "APPROVE 1ST LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    describe "trail, level" do
      let(:user) {@em_reviewer_user1}
      let(:action) {:approve}
      let(:level) {@level2}

      it_should_behave_like "trailed with right data"
      it_should_behave_like "document has moved to level"

    end

    it "Has created trail with action approve & right action user id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:approve))
      expect(last_trail&.action_user_id).to eq(@em_reviewer_user1.id)
    end

    describe "when One Reviewer is present" do
      it "has moved to next 2nd level" do
        expect(@document.controlling_level_id).to eq(@level2.id)
      end

      it "'s reviewers include level 2's reviewers" do
        expect(@document.get_reviewers.pluck(:id)).to include(*@level2.reviewers.pluck(:id))
      end

      it "'s preious level's level matches document's previous level" do
        expect(@document.get_level(:prev)&.id).to eq(@level1.id)
      end

      it "first level's document level reviewers mapping has been set to viewable" do
        previous_level_id = @document.get_level(:prev)&.id
        dlrm = @document.document_level_reviewer_mappings.with_level_id(previous_level_id).with_policy_ids(@policy.id).first

        expect(dlrm.reviewer_id).to eq(@em_reviewer_user1.id)
        expect(dlrm.action_taken_by_id).to eq(@em_reviewer_user1.id)
      end

      # it "shows up 1st level reviewers's index" do
      #   associated_documents_id = Report.reviewer_associated_items(@em_reviewer_user1).pluck(:id)
      #   expect(associated_documents_id).to include(@document.id)
      # end
      describe "shows up 1st level reviewer's index" do
        let(:reviewer) {@em_reviewer_user1}
        it_should_behave_like "reviewer has access to document"
      end

      describe "shows up 2nd level reviewer's index" do
        let(:reviewer) {@em_reviewer_user2}
        it_should_behave_like "reviewer has access to document"
      end
    end

    describe "when multiple reviewers are present" do
    end
  end

  xdescribe "RETRACT -- " do
    before(:all) do
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      @op4 = BankTransfer::PaymentRequest::Review::Retract.(@em_employee_user1, {id: @document.id})
      skip if @op4.failure?
      @document.reload
    end

    it "sets sets controlling level to nil" do
      expect(@document.controlling_level_id).to eq(nil)
    end

    describe "shows up 1st level reviewer's index" do
      let(:reviewer) {@em_reviewer_user1}
      it_should_behave_like "reviewer has access to document"
    end

    describe "shows up 2nd level reviewer's index" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer does NOT have access to document"
    end

    it "creates trail for retract with right data" do
      last_trail = @document.trails.reload.last
      expect(last_trail.action_user_id).to eq(@em_employee_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:retract))
    end
  end

  xdescribe "REJECT -- " do
    before(:all) do
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      @op4 = BankTransfer::PaymentRequest::Review::Reject.(@em_reviewer_user2, {id: @document.id, reject_note: "Test note"})
      if @op4.failure?
        p @op4.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:reject))
      expect(last_trail&.action_user_id).to eq(@em_reviewer_user2.id)
    end

    it "controlling level is set to nil" do
      expect(@document.controlling_level_id).to eq(nil)
    end

    it "status has changed" do
      expect(@document.status.id).to eq(BankPaymentRequestStatus.id_for(:rejected))
    end

    it "document's next level is first level" do
      expect(@document.get_level(:next)&.id).to eq(@level1.id)
    end

    xit "first level's document level reviewers mapping has been set to viewable" do
      previous_level_id = @document.get_level(:prev)&.id
      dlrm = @document.document_level_reviewer_mappings.with_level_id(previous_level_id).with_policy_ids(@policy.id).first

      expect(dlrm.reviewer_id).to eq(@em_reviewer_user1.id)
      expect(dlrm.action_taken_by_id).to eq(@em_reviewer_user1.id)
    end

    # it "shows up 1st level reviewers's index" do
    #   associated_documents_id = Report.reviewer_associated_items(@em_reviewer_user1).pluck(:id)
    #   expect(associated_documents_id).to include(@document.id)
    # end
    describe "shows up 1st level reviewer's index" do
      let(:reviewer) {@em_reviewer_user1}
      it_should_behave_like "reviewer has access to document"
    end

    describe "shows up 2nd level reviewer's index" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer has access to document"
    end
  end

  describe "TAKE CONTROL ON 2ND LEVEL -- " do
    before(:all) do |example|
      op = BankTransfer::PaymentRequest::Review::TakeControl.(@em_admin_user1, {id: @document.id})
      if op.failure?
        p "TAKE CONTROL ON 2ND LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:take_control))
      expect(last_trail&.action_user_id).to eq(@em_admin_user1.id)
    end

    it "is currently at level 2" do
      expect(@document.controlling_level_id).to eq(@level2.id)
    end

    it "current level dlrm has been updated with take control" do
      dlrms = @document.document_level_reviewer_mappings.where(
          level_id: @document.controlling_level_id,
          policy_id: @document.policy.id
      )

      expect(dlrms.present?).to eq(true)
      dlrms.each do |dlrm|
        expect(dlrm.taken_control).to eq(true)
        expect(dlrm.taken_control_by_id).to eq(@em_admin_user1.id)
      end
    end

    describe "show up in admin's index" do
      let(:reviewer) {@em_admin_user1}
      it_should_behave_like "reviewer has access to document"
    end
  end

  xdescribe "RETURN CONTROL TO 2ND LEVEL -- " do
    before(:all) do |example|
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      op = BankTransfer::PaymentRequest::Review::ReturnControl.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p example.description, op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_user_id).to eq(@em_admin_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:return_control))
    end

    it "current level dlrm's taken control has been set to false" do
      level_id = @document.controlling_level_id
      dlrms = @document.document_level_reviewer_mappings.with_level_id(level_id).with_policy_ids(@policy.id)

      expect(dlrms.present?).to be_truthy
      dlrms.each do |dlrm|
        expect(dlrm.taken_control).to be_falsey
        expect(dlrm.taken_control_by_id).to be_falsey
      end
    end

    describe "show up in 2nd reviewer's index" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer has access to document"
    end
  end

  describe "APPROVE AS ADMIN -- " do
    before(:all) do |example|
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      op = BankTransfer::PaymentRequest::Review::Approve.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p "APPROVE AS ADMIN", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right data" do
      last_trail = @document.trails.reload.last
      expect(last_trail.action_user_id).to eq(@em_admin_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:approve))
    end

    it "has set the next level as controlling level" do
      expect(@document.controlling_level_id).to eq(@level3.id)
    end

    it "has set previous level's document reviewer mapping to viewable" do
      previous_level_id = @document.get_level(:prev)&.id
      dlrm = @document.document_level_reviewer_mappings.with_level_id(previous_level_id).with_policy_ids(@policy.id).first

      expect(dlrm.action_taken_by_id).to eq(@em_admin_user1.id)
      expect(dlrm.reviewer_id).to eq(@em_reviewer_user2.id)
      expect(dlrm.viewable).to be_truthy
    end

    describe "show's up in reviewer 1's index" do
      let(:reviewer) {@em_reviewer_user1}
      it_should_behave_like "reviewer has access to document"
    end

    describe "show's up in reviewer 2's index" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer has access to document"
    end
  end

  xdescribe "TAKE CONTROL ON 3RD LEVEL -- " do
    before(:all) do |example|
      op = BankTransfer::PaymentRequest::Review::TakeControl.(@em_admin_user1, {id: @document.id})
      if op.failure?
        p "TAKE CONTROL ON 3RD LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:take_control))
      expect(last_trail&.action_user_id).to eq(@em_admin_user1.id)
    end

    it "is currently at level 3" do
      expect(@document.controlling_level_id).to eq(@level3.id)
    end

    it "current level dlrm has been updated with take control" do
      dlrms = @document.document_level_reviewer_mappings.where(
          level_id: @document.controlling_level_id,
          policy_id: @document.policy.id
      )

      expect(dlrms.present?).to eq(true)
      dlrms.each do |dlrm|
        expect(dlrm.taken_control).to eq(true)
        expect(dlrm.taken_control_by_id).to eq(@em_admin_user1.id)
      end
    end

    describe "show up in admin's index" do
      let(:reviewer) {@em_admin_user1}
      it_should_behave_like "reviewer has access to document"
    end
  end

  xdescribe "RETURN CONTROL TO 3RD LEVEL -- " do
    before(:all) do |example|
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      op = BankTransfer::PaymentRequest::Review::ReturnControl.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p example.description, op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_user_id).to eq(@em_admin_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:return_control))
    end

    it "current level dlrm's taken control has been set to false" do
      level_id = @document.controlling_level_id
      dlrms = @document.document_level_reviewer_mappings.with_level_id(level_id).with_policy_ids(@policy.id)

      expect(dlrms.present?).to be_truthy
      dlrms.each do |dlrm|
        expect(dlrm.taken_control).to be_falsey
        expect(dlrm.taken_control_by_id).to be_falsey
      end
    end

    describe "show up in 3rd reviewer's index" do
      let(:reviewer) {@em_reviewer_user3}
      it_should_behave_like "reviewer has access to document"
    end
  end

  xdescribe "APPROVE AS ADMIN -- " do
    before(:all) do |example|
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      op = BankTransfer::PaymentRequest::Review::Approve.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p example.description, op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right data" do
      last_trail = @document.trails.reload.last
      expect(last_trail.action_user_id).to eq(@em_admin_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:approve))
    end

    it "has set the next level as controlling level" do
      expect(@document.controlling_level_id).to be_falsey
    end

    it "has set previous level's document reviewer mapping to viewable" do
      previous_level_id = @document.get_level(:prev)&.id
      dlrm = @document.document_level_reviewer_mappings.with_level_id(previous_level_id).with_policy_ids(@policy.id).first

      expect(dlrm.action_taken_by_id).to eq(@em_admin_user1.id)
      expect(dlrm.reviewer_id).to eq(@em_reviewer_user3.id)
      expect(dlrm.viewable).to be_truthy
    end

    describe "show's up in reviewer 1's index" do
      let(:reviewer) {@em_reviewer_user1}
      it_should_behave_like "reviewer has access to document"
    end

    describe "show's up in reviewer 2's index" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer has access to document"
    end

    describe "show's up in reviewer 3's index" do
      let(:reviewer) {@em_reviewer_user3}
      it_should_behave_like "reviewer has access to document"
    end
  end

  describe "APPROVE 3RD LEVEL -- " do
    before(:all) do |example|
      skip if @document.status.id != BankPaymentRequestStatus.id_for(:processing)
      op = BankTransfer::PaymentRequest::Review::Approve.(@em_reviewer_user3, {id: @document.id})
      if op.failure?
        p "APPROVE 3RD LEVEL", op.messages[:error]
        skip if op.failure?
      end
      @document.reload
    end

    it "has created trail with action approve & right action user id" do
      last_trail = @document.trails.reload.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:approve))
      expect(last_trail&.action_user_id).to eq(@em_reviewer_user3.id)
    end

    it "has finished all levels" do
      expect(@document.controlling_level_id).to be_falsey
    end

    it "reviewers to be empty" do
      expect(@document.get_reviewers.pluck(:id).empty?).to be_truthy
    end

    it "previous level matches document's previous level" do
      expect(@document.get_level(:prev)&.id).to eq(@level3.id)
    end

    it "last level's dlrm has been set to viewable" do
      previous_level = @document.get_level(:prev)

      expect(previous_level.level_number).to eq(3)
      dlrms = @document.document_level_reviewer_mappings.with_policy_ids(@policy.id)
                  .with_level_id(previous_level.id)
      dlrms.each do |dlrm|
        expect(dlrm.action_taken_by_id).to eq(@em_reviewer_user3.id)
        expect(dlrm.viewable).to be_truthy
      end
    end

    describe "shows up 1st level reviewer's index" do
      let(:reviewer) {@em_reviewer_user1}
      it_should_behave_like "reviewer has access to document"
    end

    describe "shows up 2nd level reviewer's index" do
      let(:reviewer) {@em_reviewer_user2}
      it_should_behave_like "reviewer has access to document"
    end

    it "has set the report as approved" do
      expect(@document.status.id).to eq(BankPaymentRequestStatus.id_for(:approved))
    end
  end

end
