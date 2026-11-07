# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_trail

  # The trail currently being recorded, if any. Rides the session; single-user app.
  def current_trail
    return @current_trail if defined?(@current_trail)

    @current_trail = session[:trail_id] && Trail.find_by(id: session[:trail_id])
  end

  # The current trail, created on first use.
  def current_trail!
    current_trail || Trail.create!.tap do |trail|
      session[:trail_id] = trail.id
      @current_trail = trail
    end
  end
end
