FactoryBot.define do
  factory :blog_category do
    association :blog
    association :category
  end
end
