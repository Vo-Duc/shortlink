class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    render :index
  end

  def redirect
    code = params[:short_url]
    mapping = ShortenedUrl.find_by(short_url: code)
    if mapping
      redirect_to mapping.original_url, allow_other_host: true
    else
      render file: Rails.root.join('public/404.html'), status: :not_found, layout: false
    end
  end
end
