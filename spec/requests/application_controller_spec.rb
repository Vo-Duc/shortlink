RSpec.describe 'ApplicationController', type: :request do
  describe 'GET / (index)' do
    it 'returns 200 OK and renders the index page' do
      get '/'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('ShortLink')
      expect(response.body).to match(/<form[^>]+id="shorten-form"/)
      expect(response.body).to match(/<form[^>]+id="decode-form"/)
    end
  end

  describe 'GET /:short_code (redirect)' do
    let!(:mapping) { ShortenedUrl.create!(original_url: 'https://rails.link') }

    context 'with valid short_url' do
      it 'redirects to original_url' do
        get "/#{mapping.short_url}"
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to('https://rails.link')
      end
    end

    context 'with invalid short_url' do
      it 'returns 404 Not Found' do
        get '/nonexistent'
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("The page you were looking for doesn't exist (404)")
      end
    end
  end
end
