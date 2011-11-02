class LibraryController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]

  def index
    @items = LibraryItem.all
  end

  def update
    TorontoLibrary.all.each do |l|
      l.refresh_items
    end
    redirect_to(root_path, :notice => "Library books refreshed.") and return
  end
end
