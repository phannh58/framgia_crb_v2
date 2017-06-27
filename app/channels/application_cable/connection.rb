module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", current_user.email
    end

    protected

    def find_verified_user
      if (current_user = load_user)
        current_user
      else
        reject_unauthorized_connection
      end
    end

    def load_user
      @current_user ||= User.find_by(id: cookies.signed["user.id"])
    end
  end
end
