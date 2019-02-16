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

RSpec.describe "Money Request Workflow -- " do
  before(:all) do |example|
    @company = create(:company)
    # Create Users
    @em_employee_user1 = create(:em_employee_user, company_id: @company.id)
    @em_reviewer_user1 = create(:em_reviewer_user, company_id: @company.id)
    @em_reviewer_user2 = create(:em_reviewer_user, company_id: @company.id)
    @em_reviewer_user3 = create(:em_reviewer_user, company_id: @company.id)
    @em_finance_user1 = create(:em_finance_user, company_id: @company.id)
    @em_admin_user1 = create(:em_admin_user, company_id: @company.id)

    # Create Policy
    @policy = create(:policy, company_id: @company.id)

    # Create User Policy Mapping
    create(:policy_user_mapping, {user_id: @em_employee_user1.id, policy_id: @policy.id})

    # Create Levels
    @level1 = create(:reviewal_level, policy_id: @policy.id, associated_entity_type: 'MoneyRequestProvider')
    @level2 = create(:reviewal_level, policy_id: @policy.id, associated_entity_type: 'MoneyRequestProvider')
    @level3 = create(:reviewal_level, policy_id: @policy.id, associated_entity_type: 'MoneyRequestProvider')

    # Create level reviewer mappings
    @level1.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user1.id, threshold: 0, exception: false})
    @level2.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user2.id, threshold: 0, exception: false})
    @level3.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user3.id, threshold: 0, exception: false})

    money_request_params = {
        money_request: {
            name: "Test Money request", memo: "Test memo", travel_request_id: nil,
            required_by_date: "01-01-2019", policy_id: @policy.id,  payment_mode_id: 1,
            items_attributes: [{
                                   category_id: @company.categories.first.id, amount_attributes: {value: 1, currency_id: 1}
                               }]
        }
    }

    document_op = MoneyRequests::Create.(@em_employee_user1, money_request_params)
    if document_op.success?
      @document = MoneyRequest.first # Change this, make operation return document instead
    else
      p example.description, document_op.messages[:error]
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
      op = MoneyRequests::Submit.(@em_employee_user1, {id: @document.id})
      @document.reload
      if op.failure?
        p example.description, op.messages[:example]
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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      op = MoneyRequests::Approve.(@em_reviewer_user1, {id: @document.id})

      if op.failure?
        p example.description, op.messages[:error]
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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      @op4 = MoneyRequests::Retract.(@em_employee_user1, {id: @document.id})
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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      @op4 = MoneyRequests::Reject.(@em_reviewer_user2, {id: @document.id, reject_note: "Test note"})
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
      expect(@document.status.id).to eq(MoneyRequestStatus.id_for(:rejected))
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
      op = MoneyRequests::TakeControl.(@em_admin_user1, {id: @document.id})
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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      op = MoneyRequests::ReturnControl.(@em_admin_user1, {id: @document.id})

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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      op = MoneyRequests::Approve.(@em_admin_user1, {id: @document.id})

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

  describe "TAKE CONTROL ON 3RD LEVEL -- " do
    before(:all) do |example|
      op = MoneyRequests::TakeControl.(@em_admin_user1, {id: @document.id})
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

  describe "RETURN CONTROL TO 3RD LEVEL -- " do
    before(:all) do |example|
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      op = MoneyRequests::ReturnControl.(@em_admin_user1, {id: @document.id})

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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      op = MoneyRequests::Approve.(@em_admin_user1, {id: @document.id})

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
      skip if @document.status.id != MoneyRequestStatus.id_for(:processing)
      op = MoneyRequests::Approve.(@em_reviewer_user3, {id: @document.id})
      if op.failure?
        p example.description, op.messages[:error]
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
      expect(@document.status.id).to eq(MoneyRequestStatus.id_for(:approved))
    end
  end

end
