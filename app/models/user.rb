class User < ActiveRecord::Base
  # In case you’re wondering why we don’t just use the signed user id, 
  # without the remember token, this would allow an attacker with possession 
  # of the encrypted id to log in as the user in perpetuity. 
  # In the present design, an attacker with both cookies can log in as the user only until the user logs out.
  attr_accessor :remember_token
  # Some database adapters use case-sensitive indices, considering the strings “Foo@ExAMPle.CoM” 
  # and “foo@example.com” to be distinct, but our application treats those addresses as the same. 
  # To avoid this incompatibility, we’ll standardize on all lower-case addresses, 
  # converting “Foo@ExAMPle.CoM” to “foo@example.com” before saving it to the database.
  before_save { self.email = email.downcase }
  #same as: validates(:name, presence: true)
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
  format: { with: VALID_EMAIL_REGEX }, 
  uniqueness: { case_sensitive: false }
  # has_secure_password includes a separate presence validation that specifically catches nil passwords
  has_secure_password
  # with allow_nil: true, nil passwords now bypass the main presence validation but are still caught by has_secure_password
  # needed for when user wants to update their profile and leave password empty(intended for no change)
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    # Explained in tutorial 8.4.2
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
