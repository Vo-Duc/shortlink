RSpec.describe Api::V1::ShortLinksController, type: :controller do
  describe 'POST #encode' do
    it 'returns a short URL' do
      post :encode, params: { original_url: 'https://example.com' }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['short_url']).to match(/^http/)
    end

    it 'returns an existing short URL if the original URL already exists' do
      existing_url = ShortenedUrl.create!(original_url: 'https://example.com')
      post :encode, params: { original_url: 'https://example.com' }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['short_url']).to eq "#{request.base_url}/#{existing_url.short_url}"
    end

    it 'returns a 400 error when no original_url is provided' do
      post :encode, params: {}
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 422 error when the original_url is invalid' do
      post :encode, params: { original_url: 'htt://www.ruby-lang.org/en/' }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['error']).to include('Original url must be a valid URL')
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
