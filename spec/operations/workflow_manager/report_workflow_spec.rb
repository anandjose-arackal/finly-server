require 'rails_helper'

# Testing Instructions

RSpec.describe "Report Workflow -- " do
  before(:all) do
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
    @policy2 = create(:policy, company_id: @company.id)

    # Create User Policy Mapping
    create(:policy_user_mapping, {user_id: @em_employee_user1.id, policy_id: @policy.id})
    create(:policy_user_mapping, {user_id: @em_employee_user1.id, policy_id: @policy2.id})

    # Create Levels
    @level1 = create(:reviewal_level, policy_id: @policy.id)
    @level2 = create(:reviewal_level, policy_id: @policy.id)
    @level3 = create(:reviewal_level, policy_id: @policy.id)

    @level_p2_1 = create(:reviewal_level, policy_id: @policy2.id)
    @level_p2_2 = create(:reviewal_level, policy_id: @policy2.id)
    @level_p2_3 = create(:reviewal_level, policy_id: @policy2.id)

    # Create level reviewer mappings
    @level1.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user1.id, threshold: 0, exception: false})
    @level2.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user2.id, threshold: 0, exception: false})
    @level3.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user3.id, threshold: 0, exception: false})

    # Createe LURM for overriding reviewer on a default LRM mapping
    @level1.level_user_reviewer_mappings.create({user_id: @em_employee_user1.id, reviewer_id: @em_reviewer_user4.id, policy_id: @policy.id})

    @level_p2_1.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user3.id, threshold: 0, exception: false})
    @level_p2_2.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user1.id, threshold: 0, exception: false})
    @level_p2_3.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user2.id, threshold: 0, exception: false})

    expense = create(:expense, {user_id: @em_employee_user1.id,
                                spent_from_id: @em_employee_user1.user_pockets.reimbursement_pocket_only.first.id})

    document_op = Reports::Create.(@em_employee_user1, {expense_ids: [expense.id], policy_id: @policy.id})

    if document_op.success?
      @document = Report.first # Change this, make operation return document instead
      # document_update_op = Reports::Update.(@em_employee_user1, {document: {policy_id: @policy.id}})
    end
  end

  describe "CREATE -- " do
    it "has created document level reviewer mapping" do
      expect(@document.document_level_reviewer_mappings.count).to eq(3)
    end

    it "has set override user as approver on first level dlrm" do
      debugger
    end

  end

  xdescribe "UPDATE -- " do
    before(:all) do |example|
      # @old_policy_id = @policy.id
      # @policy = @policy2
      # Update report

      op = Reports::Update.(@em_employee_user1, {id: @document.id, policy_id: @policy2.id})

      if op.failure?
        p "UPDATE", op.messages[:error]
        skip
      end
    end

    it "has deleted old DLRMs and created new ones" do
      old_dlrm = @document.document_level_reviewer_mappings.with_policy_ids(@policy.id)
      new_dlrm = @document.document_level_reviewer_mappings.with_policy_ids(@policy2.id)

      expect(old_dlrm.count).to eq(0)
      expect(new_dlrm.count).to eq(3)
    end

    it "has right reviewers in right levels in dlrm" do
      dlrm_l1 = @document.document_level_reviewer_mappings.with_policy_ids(@policy2.id).with_level_id(@level_p2_1).first
      dlrm_l2 = @document.document_level_reviewer_mappings.with_policy_ids(@policy2.id).with_level_id(@level_p2_2).first
      dlrm_l3 = @document.document_level_reviewer_mappings.with_policy_ids(@policy2.id).with_level_id(@level_p2_3).first

      expect(dlrm_l1.reviewer.id).to eq(@em_reviewer_user3.id)
      expect(dlrm_l2.reviewer.id).to eq(@em_reviewer_user1.id)
      expect(dlrm_l3.reviewer.id).to eq(@em_reviewer_user2.id)
    end
  end

  describe "SUBMIT -- " do
    before(:all) do
      @op2 = Reports::Submit.(@em_employee_user1, {id: @document.id})
      @document.reload
      if @op2.failure?
        p "SUBMIT", @op2.messages[:error]
        skip
      end
    end

    it "has created last trail with action :submit and action user id" do
      last_trail = @document.trails.natural_order.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:submit))
      expect(last_trail&.action_user_id).to eq(@em_employee_user1.id)
    end

    # it "is submitted successfully" do
    #   expect(@op2.success?).to eq true
    # end

    it "has moved to first level" do
      expect(@document.controlling_level_id).to eq(@level1.id)
    end

    it "'s reviewer is set to level 1's reviewer" do
      expect(@document.get_reviewers.pluck(:id)).to include(*@level1.reviewers.pluck(:id))
    end


    it "shows up 1st level reviewers's index" do
      associated_documents_id = Report.reviewer_associated_items(@em_reviewer_user1).pluck(:id)
      expect(associated_documents_id).to include(@document.id)
    end

    it "doensn't shows up 2nd level reviewers's index yet" do
      associated_documents_id = Report.reviewer_associated_items(@em_reviewer_user2).pluck(:id)
      expect(associated_documents_id).not_to include(@document.id)
    end
  end

  describe "APPROVE 1ST LEVEL -- " do
    before(:all) do
      skip if @document.status.id != ReportStatus.id_for(:processing)
      @op3 = Reports::Approve.(@em_reviewer_user1, {id: @document.id})
      @document.reload
      skip if @op3.failure?
    end

    it "Has created trail with action approve & right action user id" do
      last_trail = @document.trails.natural_order.reload.last
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
      skip if @document.status.id != ReportStatus.id_for(:processing)
      @op4 = Reports::Retract.(@em_employee_user1, {id: @document.id})
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
      last_trail = @document.trails.natural_order.reload.last
      expect(last_trail.action_user_id).to eq(@em_employee_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:retract))
    end
  end

  xdescribe "REJECT -- " do
    before(:all) do
      skip if @document.status.id != ReportStatus.id_for(:processing)
      @op4 = Reports::Reject.(@em_reviewer_user2, {id: @document.id, reject_note: "Test note"})
      if @op4.failure?
        p @op4.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.natural_order.reload.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:reject))
      expect(last_trail&.action_user_id).to eq(@em_reviewer_user2.id)
    end

    it "controlling level is set to nil" do
      expect(@document.controlling_level_id).to eq(nil)
    end

    it "status has changed" do
      expect(@document.status.id).to eq(ReportStatus.id_for(:rejected))
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
      op = Reports::TakeControl.(@em_admin_user1, {id: @document.id})
      if op.failure?
        p "TAKE CONTROL ON 2ND LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.natural_order.reload.last
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
      skip if @document.status.id != ReportStatus.id_for(:processing)
      op = Reports::ReturnControl.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p "RETURN CONTROL TO 2ND LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.natural_order.reload.last
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
      skip if @document.status.id != ReportStatus.id_for(:processing)
      op = Reports::Approve.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p 'APPROVE AS ADMIN', op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right data" do
      last_trail = @document.trails.natural_order.reload.last
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
      op = Reports::TakeControl.(@em_admin_user1, {id: @document.id})
      if op.failure?
        p "TAKE CONTROL ON 3RD LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.natural_order.reload.last
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
      skip if @document.status.id != ReportStatus.id_for(:processing)
      op = Reports::ReturnControl.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p "RETURN CONTROL TO 3RD LEVEL", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.natural_order.reload.last
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
      skip if @document.status.id != ReportStatus.id_for(:processing)
      op = Reports::Approve.(@em_admin_user1, {id: @document.id})

      if op.failure?
        p "APPROVE AS ADMIN", op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right data" do
      last_trail = @document.trails.natural_order.reload.last
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
      skip if @document.status.id != ReportStatus.id_for(:processing)
      op = Reports::Approve.(@em_reviewer_user3, {id: @document.id})
      if op.failure?
        p "APPROVE 3RD LEVEL", op.messages[:error]
        skip if op.failure?
      end
      @document.reload
    end

    it "has created trail with action approve & right action user id" do
      last_trail = @document.trails.natural_order.reload.last
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
      expect(@document.status.id).to eq(ReportStatus.id_for(:approved))
    end
  end

end
