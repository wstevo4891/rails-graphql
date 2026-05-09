FactoryBot.define do
  factory :blog do
    association :user
    title { "Sample Blog Title" }
    description { "This is a sample blog description." }
  end
end
