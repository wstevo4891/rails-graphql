FactoryBot.define do
  factory :comment do
    association :blog
    association :user
    text { "A sample comment." }
  end
end
