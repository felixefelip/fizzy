# rbs_inline: enabled

class Notifier::MentionNotifier < Notifier
  alias mention source

  private
    #: -> Array[::Notifier::_Recipient]
    def recipients
      if mention.self_mention?
        []
      else
        [ mention.mentionee ]
      end
    end

    #: -> User
    def creator
      mention.mentioner
    end
end
