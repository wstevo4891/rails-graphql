FactoryBot.define do
  factory :category do
    sequence(:slug) { |n| "category-#{n}" }
    title { "Sample Category" }
    description { "A sample category description." }
  end
end
