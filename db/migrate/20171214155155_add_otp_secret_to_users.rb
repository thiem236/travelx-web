class AddOtpSecretToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :otp_secret, :string
  end
end
