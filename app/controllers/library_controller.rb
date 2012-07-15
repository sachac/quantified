class LibraryController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :current]
  respond_to :html, :xml, :json, :csv

  def index
    authorize! :manage_account, current_account
    @items = current_account.library_items
    respond_with @items
  end

  def update
    authorize! :manage_account, current_account
    current_account.toronto_libraries.each do |l|
      l.refresh_items
    end
    redirect_to(root_path, :notice => "Library books refreshed.") and return
  end

end
