require "rails_helper"

RSpec.describe Types::BlogType do
  let(:user) { create(:user) }

  describe "querying all blogs" do
    let(:query) do
      <<~GQL
        {
          blogs {
            id
            title
            description
            userName
          }
        }
      GQL
    end

    subject(:fetch_all) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_all.to_h["data"]["blogs"] }

    context "when blogs exist" do
      let!(:blogs) { create_list(:blog, 5, user: user) }

      it "returns the expected number of results" do
        expect(response.size).to eq(5)
      end

      it "returns blog IDs" do
        blog_id = response.first["id"].to_i
        expect(blog_id).to be_a(Integer)
      end

      it "returns blog titles" do
        actual = response.first["title"]
        expected = blogs.first.title
        expect(actual).to eq(expected)
      end

      it "returns blog descriptions" do
        actual = response.first["description"]
        expected = blogs.first.description
        expect(actual).to eq(expected)
      end

      it "returns blog userNames" do
        actual = response.first["userName"]
        expected = "#{user.first_name} #{user.last_name}"
        expect(actual).to eq(expected)
      end
    end

    context "when blogs do not exist" do
      it "returns an empty response" do
        expect(response).to be_empty
      end
    end
  end

  describe "querying a blog by ID" do
    let!(:blog) { create(:blog, user: user) }
    let(:blog_id) { blog.id }

    let(:query) do
      <<~GQL
        {
          blog(id: #{blog_id}) {
            id
            title
            description
            userName
          }
        }
      GQL
    end

    subject(:fetch_blog) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_blog.to_h["data"]["blog"] }

    let(:error_message) { fetch_blog.to_h["errors"].first["message"] }

    it "returns the blog ID" do
      actual = response["id"].to_i
      expect(actual).to eq(blog.id)
    end

    it "returns the blog title" do
      expect(response["title"]).to eq(blog.title)
    end

    it "returns the blog description" do
      expect(response["description"]).to eq(blog.description)
    end

    it "returns the blog userName" do
      expected = "#{user.first_name} #{user.last_name}"
      expect(response["userName"]).to eq(expected)
    end

    context "when blog does not exist" do
      let(:blog_id) { 0 }

      it "returns an error response" do
        expect(error_message).to match(/Record not found/)
      end
    end

    describe "with variables" do
      let(:query) do
        <<~GQL
          query getBlog($id: ID!) {
            blog(id: $id) {
              id
              title
              description
            }
          }
        GQL
      end

      subject(:fetch_blog) do
        RailsGraphqlSchema.execute(query, variables: { id: blog_id })
      end

      it "returns the blog ID" do
        actual = response["id"].to_i
        expect(actual).to eq(blog.id)
      end

      it "returns the blog title" do
        expect(response["title"]).to eq(blog.title)
      end

      it "returns the blog description" do
        expect(response["description"]).to eq(blog.description)
      end

      context "when blog does not exist" do
        let(:blog_id) { 0 }

        it "returns an error response" do
          expect(error_message).to match(/Record not found/)
        end
      end
    end
  end
end
