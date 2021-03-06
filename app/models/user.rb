class User < ActiveRecord::Base
  # In case you’re wondering why we don’t just use the signed user id, 
  # without the remember token, this would allow an attacker with possession 
  # of the encrypted id to log in as the user in perpetuity. 
  # In the present design, an attacker with both cookies can log in as the user only until the user logs out.
  attr_accessor :remember_token, :activation_token, :reset_token
  # Some database adapters use case-sensitive indices, considering the strings “Foo@ExAMPle.CoM” 
  # and “foo@example.com” to be distinct, but our application treats those addresses as the same. 
  # To avoid this incompatibility, we’ll standardize on all lower-case addresses, 
  # converting “Foo@ExAMPle.CoM” to “foo@example.com” before saving it to the database.
  before_save { email.downcase! }
  before_create :create_activation_digest
  #same as: validates(:name, presence: true)
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
  format: { with: VALID_EMAIL_REGEX }, 
  uniqueness: { case_sensitive: false }
  # has_secure_password includes a separate presence validation that specifically catches nil passwords
  has_secure_password
  # with allow_nil: true, nil passwords now bypass the main presence validation but are still caught by has_secure_password
  # needed for when user wants to update their profile and leave password empty(intended for no change)
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # 12.1.4 Using the source parameter, which explicitly tells Rails that the source of the following array is the set of followed ids.
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # 12.1.5 we could actually omit the :source key for followers, because in the case of a :followers attribute, 
  # Rails will singularize “followers” and automatically look for the foreign key follower_id in this case.
  has_many :followers, through: :passive_relationships, source: :follower

  # Defining class methods and wrap them within class << self
  # Can also use, User.digest or self.digest to define to methods without the wrap.
  class << self
    # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
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
  def authenticated?(attribute, token)
    # Ruby metaprogramming, send method, which lets us call a method with a name of our choice by “sending a message” to a given object.
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    # Explained in tutorial 8.4.2
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    # Hit Database twice
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    # Hit Database once
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    # Hit Database twice
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    # Hit Database once
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  def feed
    # where using SQL query, using ? is Rails way to escape the query parameters, thus avoiding SQL injection.
    # here id is not from user input, so it is safe here to just embeded in the query like "user_id = #{id}",
    # just a good practice to always escape for "where" query. Refer: tutorial 11.3.3
    # Micropost.where("user_id = ?", id)

    # IN will take a string and test if it contains the user_id.
    # following_ids is synthesized by Active Record based on the has_many :following association
    # the result is that we need only append _ids to the association name to get the ids corresponding to the user.following collection.
    # A string of followed user ids can be: User.first.following_ids.join(', ')
    # When inserting into an SQL string, the ? interpolation takes care of it and in fact eliminates some database-dependent incompatibilities,
    # so that we can use following_ids by itself (14.3.2)
    # drawback: following_ids pulls all the followed users’ ids into memory, and creates an array the full length of the followed users array
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

    # 14.3.3 following_ids here is just raw SQL string.
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      # before_create callback happens before the user has been created. 
      # As a result of the callback, when a new user is defined with User.new (as in user signup), 
      # it will automatically get both activation_token and activation_digest attributes; 
      # because the latter is associated with a column in the database, it will be written automatically when the user is saved.
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
