FactoryBot.define do
  factory :shortened_url do
    original_url { Faker::Internet.url }
    short_url { SecureRandom.alphanumeric(6) }
  end
end
