class FoodsController < ApplicationController
  # GET /foods
  # GET /foods.xml
  respond_to :html, :xml, :json, :csv

  def index
    authorize! :view_food, current_account
    @info = Hash.new
    current_account.csa_foods.all.each do |log|
      @info[log.food_id] ||= Hash.new
      @info[log.food_id][:unit] = log.unit
      @info[log.food_id][:total] ||= 0
      @info[log.food_id][:total] += log.quantity
      @info[log.food_id][:remaining] ||= 0
      if log.disposition.blank?
        @info[log.food_id][:remaining] += log.quantity
      end
    end
    @foods = current_account.foods.all
    respond_with @foods
  end

  # GET /foods/1
  # GET /foods/1.xml
  def show
    @food = current_account.foods.find(params[:id])
    authorize! :view, @food
    respond_with @food
  end

  # GET /foods/new
  # GET /foods/new.xml
  def new
    authorize! :manage_account, current_account
    @food = current_account.foods.new
    respond_with @food
  end

  # GET /foods/1/edit
  def edit
    authorize! :manage_account, current_account
    @food = current_account.foods.find(params[:id])
  end

  # POST /foods
  # POST /foods.xml
  def create
    authorize! :manage_account, current_account
    @food = current_account.foods.new(params[:food])
    add_flash :notice, I18n.t('food.created') if @food.save
    respond_with @food
  end

  # PUT /foods/1
  # PUT /foods/1.xml
  def update
    authorize! :manage_account, current_account
    @food = current_account.foods.find(params[:id])
    params[:food].delete(:user_id)
    add_flash :notice, I18n.t('food.updated') if @food.update_attributes(params[:food])
    respond_with @food
  end

  # DELETE /foods/1
  # DELETE /foods/1.xml
  def destroy
    authorize! :manage_account, current_account
    @food = current_account.foods.find(params[:id])
    @food.destroy
    respond_with @food, :location => foods_url
  end
end
