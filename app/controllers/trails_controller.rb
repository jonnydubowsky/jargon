# frozen_string_literal: true

class TrailsController < ApplicationController
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
