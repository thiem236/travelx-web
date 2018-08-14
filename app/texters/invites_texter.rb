class InvitesTexter < Textris::Base
  default :from => "Travel +16693337539 "

  def send_invite(invite)
    @invite = invite
    @user = invite.user
    text to: invite.contact
  end

end