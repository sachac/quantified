class Api::Offline::V1::OfflineController < ApplicationController
  layout 'offline'
  def track
    authorize! :manage_account, current_account
    @categories = current_account.record_categories.order('full_name')
  end
end
