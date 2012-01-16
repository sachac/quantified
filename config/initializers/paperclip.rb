Paperclip::Attachment.interpolations[:user_id] = proc do |attachment, style|
  attachment.instance.user_id
end
