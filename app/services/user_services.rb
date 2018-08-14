class UserServices
  attr_accessor :user_params, :current_user
  def initialize(params)
    @current_user =  params[:current_user]
    @user_params =  params[:user_params]
  end


  def invite_users(params)
    users = []
    params.each do |user_param|
      user = User.find_by(email: user_param['email'])
      if user.present?
        users << user
      else
        users << User.invite!(invite_params(user_param),@current_user)
      end

    end
    users
  end

  def sync_friend
    contacts = user_params[:contacts]
    contacts.map! { |element|
      unless element.start_with?('0','+')
        '+' + element
      else
        element
      end
    }
    users = User.where(contact: contacts).where.not(id: @current_user.id)
    users.each do |c|
      users = users - [c] unless @current_user.auto_add_friend(c)
    end
    users
  end

  def sync_email_or_contact
    save_contact
    contacts = user_params[:contacts]
    contacts.map! { |element|
      unless element.start_with?('0','+')
        '+' + element
      else
        element
      end
    }
    friends = []
    users = User.where(contact: contacts).or(User.where(email: user_params[:emails])).where.not(id: @current_user.id)

    users.each do |c|
      if @current_user.friend_has_contact?(c)
        friends << UserSerializer.new(c) if @current_user.auto_add_friend(c)
      else
        if @current_user.friend_request(c)
          noti = NotificationServices.new(c,@current_user,nil)
          noti.send_noti_add_friend('invited_friend')
        end

      end
    end

    request_friend = @current_user.pending_friends.map{|c|UserSerializer.new(c) }
    {new_friends: friends, request_friends: request_friend}
  end

  def sync_friend_from_fb
    fb_ids = user_params[:fb_ids] || []
    if fb_ids.length > 0
      users = User.where(fb_id: fb_ids).where.not(id: @current_user.id)
      users.each do |c|
        @current_user.auto_add_friend(c)
      end
    end

    @current_user.friends.where.not(fb_id: nil)
  end

  def save_contact
    contacts = user_params[:contacts]
    if contacts.is_a?Array
      contacts.map! { |element|
        unless element.start_with?('0','+')
          '+' + element
        else
          element
        end
      }
      contacts.each do |contact|
        Contact.phone.find_or_create_by(user_id: @current_user.id, contact: contact).delay
      end
    end
    if user_params[:emails].is_a?Array
      user_params[:emails].each do |email|
        Contact.email.find_or_create_by(user_id: @current_user.id, contact: email).delay
      end

    end


  end

  def invite_params(user_params)
    user_params.permit(:name, :email)
  end
end