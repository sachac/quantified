class LibraryController < ApplicationController
  def index
    @items = LibraryItem.all
  end

  def update
    l = TorontoLibrary.new
    l.refresh_items
    redirect_to(root_path, :notice => "Library books refreshed.") and return
  end
end
