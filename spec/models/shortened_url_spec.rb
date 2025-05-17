require 'rails_helper'

RSpec.describe ShortenedUrl, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:original_url) }

    it 'validates format of original_url' do
      valid_url = ShortenedUrl.new(original_url: 'https://example.com')
      invalid_url = ShortenedUrl.new(original_url: 'not_a_url')

      expect(valid_url).to be_valid
      expect(invalid_url).not_to be_valid
      expect(invalid_url.errors[:original_url]).not_to be_empty
    end

    it 'validates uniqueness of short_url' do
      existing = create(:shortened_url)
      duplicate = build(:shortened_url, short_url: existing.short_url)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:short_url]).to include('has already been taken')
    end
  end

  describe 'short_url generation' do
    it 'generates a short_url before creation' do
      shortened = ShortenedUrl.create(original_url: 'https://example.com')
      expect(shortened.short_url).to be_present
      expect(shortened.short_url.length).to eq(6)
    end

    it 'generates a unique short_url even when collisions happen' do
      allow(SecureRandom).to receive(:alphanumeric).and_return('abcdef', 'abcdef', 'ghijkl')

      create(:shortened_url, short_url: 'abcdef') # force collision
      shortened = ShortenedUrl.create(original_url: 'https://example.com')

      expect(shortened.short_url).to eq('ghijkl')
    end
  end
end
