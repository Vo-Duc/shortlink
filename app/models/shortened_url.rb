class ShortenedUrl < ApplicationRecord
  validates :original_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp
  validates :short_url, uniqueness: true

  before_create :generate_short_url

  private

  def generate_short_url
    loop do
      self.short_url = SecureRandom.alphanumeric(6)
      break unless ShortenedUrl.exists?(short_url: short_url)
    end
  end
end

# == Schema Information
#
# Table name: shortened_urls
#
#  created_at   :datetime         not null
#  id           :bigint(8)        not null, primary key
#  original_url :string
#  short_url    :string
#  updated_at   :datetime         not null
#
