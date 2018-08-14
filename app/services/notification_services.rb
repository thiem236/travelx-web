class NotificationServices
  attr_accessor :user, :sender, :obj
  def initialize(user, sender,obj)
    @user = user
    @sender = sender
    @obj = obj
  end

  def send_noti_action(action)
    if @user.id == @sender.id
      return
    end
    payload = {
        content_available: true,
        mutable_content: true,
        badge: 1,
        notification:
            {
                body:map_text(action)[:messeage],
                sound: "default",
                message:  map_text(action)[:messeage]
            },
        data: {push_type: map_text(action)[:type]}
    }
    token  = @user.device_tokens.first
    payload[:to] = token['device_token'] rescue ""
    payload[:badge] = @user.push_badge
    Notification.create!(
        device_id: if token then token['device_token'] else "" end ,
        device:  if token then token['device_name'] else "" end ,
        user_id: @user.id,
        sender_id: @sender.id,
        body: payload,
        push_device: true,
        noti_type: action,
        title: map_text(action)[:title],
        obj: map_text(action)[:obj],
        model_type: map_text(action)[:type],
        able_type: @obj.class.name,
        able_id: @obj.id,
    )
    @user.push_badge = @user.push_badge + 1
    @user.save!
  end

  def send_noti_add_friend(action)
    if @user.id == @sender.id
      return
    end
    payload = {
        content_available: true,
        mutable_content: true,
        badge: 1,
        notification:
            {
                body:"#{@sender.name} #{map_action(action)}",
                sound: "default",
                message:  "#{@sender.name} #{map_action(action)}"
            },
        data: {push_type: action}
    }
    token  = @user.device_tokens.first
    payload[:to] = token['device_token'] rescue ""
    payload[:badge] = @user.push_badge
    Notification.create(
        device_id: if token then token['device_token'] else "" end ,
        device:  if token then token['device_name'] else "" end ,
        user_id: @user.id,
        sender_id: @sender.id,
        body: payload,
        push_device: true,
        noti_type: action,
        title: action,
        obj: {},
        model_type: 'Friend',
        able_type: nil,
        able_id: nil,
    ).delay
    @user.push_badge = @user.push_badge + 1
    @user.save!
  end

  def map_text(action)
    case @obj.class.name
      when 'Attachment'
        {
            type: 'Image',
            messeage: "#{@sender.name}  #{action} your #{@obj.caption} photo",
            title: "#{action} your #{@obj.caption} photo",
            obj: AttachmentSerializer.new(@obj)
        }
      when 'City'
        {type: 'City',
         messeage: "#{@sender.name} #{action} your #{@obj.name} city ",
         title:  "#{action} your #{@obj.name} city",
         obj: CitySerializer.new(@obj)
        }
      else
        {type: 'City', messeage: "#{@sender.name} have #{action} your trip",title: ''}
    end
  end

  def map_action(action)
    case action
      when 'accepted_friend'
        'has accepted your friend request'
      when 'invited_friend'
        ' has sent a friend request'
    end
  end


end