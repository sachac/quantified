class LibraryController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :current]

  def index
    @items = LibraryItem.all
    authorize! :manage_account, current_account
  end

  def update
    authorize! :manage_account, current_account
    TorontoLibrary.all.each do |l|
      l.refresh_items
    end
    redirect_to(root_path, :notice => "Library books refreshed.") and return
  end

end
