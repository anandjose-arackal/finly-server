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

RSpec.describe "Report Workflow" do
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

    # Create User Policy Mapping
    create(:policy_user_mapping, {user_id: @em_employee_user1.id, policy_id: @policy.id})

    # Create Levels
    @level_1 = create(:reviewal_level, policy_id: @policy.id)
    @level_2 = create(:reviewal_level, policy_id: @policy.id)
    @level_3 = create(:reviewal_level, policy_id: @policy.id)

    # Create level reviewer mappings
    @level_1.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user1.id, threshold: 0, exception: false})
    @level_2.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user2.id, threshold: 0, exception: false})
    @level_3.level_reviewer_mappings.create({reviewer_id: @em_reviewer_user3.id, threshold: 0, exception: false})

    expense = create(:expense, {user_id: @em_employee_user1.id,
                                spent_from_id: @em_employee_user1.user_pockets.reimbursement_pocket_only.first.id})

    document_op = Reports::Create.(@em_employee_user1, {expense_ids: [expense.id], policy_id: @policy.id})

    if document_op.success?
      @document = Report.first # Change this, make operation return document instead
      # document_update_op = Reports::Update.(@em_employee_user1, {document: {policy_id: @policy.id}})
    end
  end

  describe "Report Creation" do
    it "has created document level reviewer mapping" do
      expect(@document.document_level_reviewer_mappings.count).to eq(3)
    end
  end

  describe "Report Submission Do" do
    before(:all) do
      @op2 = Reports::Submit.(@em_employee_user1, {id: @document.id})
      @document.reload
      skip if @op2.failure?
    end

    it "has created last trail with action :submit and action user id" do
      last_trail = @document.trails.natural_order.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:submit))
      expect(last_trail&.action_user_id).to eq(@em_employee_user1.id)
    end

    it "is submitted successfully" do
      expect(@op2.success?).to eq true
    end

    it "has moved to first level" do
      expect(@document.controlling_level_id).to eq(@level_1.id)
    end

    it "'s reviewer is set to level 1's reviewer" do
      expect(@document.get_reviewers.pluck(:id)).to include(*@level_1.reviewers.pluck(:id))
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

  describe "Report Apprval 1st level" do
    before(:all) do
      skip if @document.status.id != ReportStatus.id_for(:processing)
      @op3 = Reports::Approve.(@em_reviewer_user1, {id: @document.id})
      @document.reload
      skip if @op3.failure?
    end

    it "Has created trail with action approve & right action user id" do
      last_trail = @document.trails.natural_order.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:approve))
      expect(last_trail&.action_user_id).to eq(@em_reviewer_user1.id)
    end

    describe "when One Reviewer is present" do
      it "has moved to next 2nd level" do
        expect(@document.controlling_level_id).to eq(@level_2.id)
      end

      it "'s reviewers include level 2's reviewers" do
        expect(@document.get_reviewers.pluck(:id)).to include(*@level_2.reviewers.pluck(:id))
      end

      it "'s preious level's level matches document's previous level" do
        expect(@document.get_level(:prev)&.id).to eq(@level_1.id)
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

  xdescribe "Report Retraction after 1st Level Approval" do
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
      last_trail = @document.trails.natural_order.last
      expect(last_trail.action_user_id).to eq(@em_employee_user1.id)
      expect(last_trail.action_id).to eq(TrailAction.id_for(:retract))
    end
  end

  xdescribe "Report Rejection at 2nd level" do
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
      last_trail = @document.trails.natural_order.last
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
      expect(@document.get_level(:next)&.id).to eq(@level_1.id)
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

  describe "Report Take Control by Admin" do
    before(:all) do
      op = Reports::TakeControl.(@em_admin_user1, {id: @document.id})
      if op.failure?
        p op.messages[:error]
        skip
      end
      @document.reload
    end

    it "trailed with right action user id & action id" do
      last_trail = @document.trails.natural_order.last
      expect(last_trail&.action_id).to eq(TrailAction.id_for(:take_control))
      expect(last_trail&.action_user_id).to eq(@em_admin_user1.id)
    end

    it "is currently at level 2" do
      expect(@document.controlling_level_id).to eq(@level_2.id)
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
end
