require "rails_helper"

RSpec.describe Comment, type: :model do
  subject(:comment) { build(:comment) }

  describe "factory" do
    it "builds a valid comment" do
      expect(comment).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:blog) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:text) }

    it "is invalid without text" do
      comment.text = ""

      expect(comment).not_to be_valid
      expect(comment.errors[:text]).to include("can't be blank")
    end
  end

  describe ".save" do
    it "creates a new record" do
      expect { comment.save! }.to change { Comment.count }.by(1)
    end
  end
end
