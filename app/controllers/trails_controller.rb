# frozen_string_literal: true

class TrailsController < ApplicationController
  def index
    @trails = Trail.joins(:trail_steps).distinct.order(created_at: :desc).limit(50).includes(:trail_steps)
  end

  def show
    @trail = Trail.find(params[:id])
  end

  def create
    session[:trail_id] = nil
    redirect_to root_path, notice: "Started a new trail."
  end

  def update
    trail = Trail.find(params[:id])
    trail.update!(name: params[:trail][:name].presence)
    redirect_to trail
  end
end
