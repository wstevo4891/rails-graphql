FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    first_name { "Test" }
    last_name { "User" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    role { :author }
  end
end
