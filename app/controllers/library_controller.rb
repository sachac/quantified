class LibraryController < ApplicationController
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
