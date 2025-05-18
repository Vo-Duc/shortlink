RSpec.describe 'Redirect Short URLs', type: :request do
  let!(:mapping) { ShortenedUrl.create!(original_url: 'https://rails.link') }

  it 'redirects to original_url' do
    get "/#{mapping.short_url}"
    expect(response).to redirect_to('https://rails.link')
  end

  it 'returns 404 for unknown short_url' do
    get '/unknowncode'
    expect(response).to have_http_status(:not_found)
  end
end
