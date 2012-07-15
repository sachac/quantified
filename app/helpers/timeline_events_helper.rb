module TimelineEventsHelper
  def explain_event(e)
    case e.subject_type
    when 'ClothingLog'
      "#{l e.actor.name, e.actor} wore #{l e.secondary_subject.name, e.secondary_subject} on #{l e.subject.date, e.subject}" 
    end
  end
end
