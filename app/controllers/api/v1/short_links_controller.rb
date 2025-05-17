class Api::V1::ShortLinksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def encode
    url = ShortenedUrl.find_or_create_by(original_url: params[:original_url])

    render json: { short_url: url.short_url }, status: :ok
  end

  def decode
    short_url = params[:short_url].split('/').last
    url = ShortenedUrl.find_by(short_url: short_url)
    if url
      render json: { original_url: url.original_url }, status: :ok
    else
      render json: { error: "Short URL not found" }, status: :not_found
    end
  end
end
