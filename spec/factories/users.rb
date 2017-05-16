FactoryGirl.define do
  factory :user do
    name { Faker::Name.first_name  }
    surname { Faker::Name.last_name  }
    hobby { Faker::Beer.name }
  end
end