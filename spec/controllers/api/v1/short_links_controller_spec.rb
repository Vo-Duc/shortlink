RSpec.describe Api::V1::ShortLinksController, type: :controller do
  describe 'POST #encode' do
    it 'returns a short URL' do
      post :encode, params: { original_url: 'https://example.com' }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['short_url']).to match(/^http/)
    end

    it 'returns a 400 error when no original_url is provided' do
      post :encode, params: {}
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST #decode' do
    let!(:url) { ShortenedUrl.create!(original_url: 'https://a.com') }

    it 'returns the original URL for a valid short URL' do
      post :decode, params: { short_url: "http://x/#{url.short_url}" }
      json = JSON.parse(response.body)
      expect(json['original_url']).to eq 'https://a.com'
    end

    it 'returns a 404 error for an invalid short URL' do
      post :decode, params: { short_url: 'http://x/xxxxxx' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
