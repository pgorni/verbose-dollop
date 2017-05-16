require 'securerandom'

FactoryGirl.define do
  factory :auth_token do
    uuid { SecureRandom.uuid }
    secret_token { Faker::Omniauth.facebook[:credentials][:token] }
  end
end