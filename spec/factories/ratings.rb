FactoryBot.define do
  factory :rating do
    association :blog
    association :user
    rating { 4.5 }
  end
end
