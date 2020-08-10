class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.user.email_regex
  USERS_PARAMS = %i(name email password password_confirmation).freeze

  attr_accessor :remember_token, :activation_token, :reset_token

  scope :is_activated, ->{where activated: true}

  validates :name, presence: true,
    length: {maximum: Settings.user.username_maximum}

  validates :email, presence: true,
    length: {maximum: Settings.user.email_maximum},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true

  validates :password, presence: true,
    length: {minimum: Settings.user.password_minimum},
    allow_nil: true

  has_secure_password

  before_create :create_activation_digest
  before_save :email_downcase

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def forget
    update remember_digest: nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    digest_token = User.digest reset_token
    update reset_digest: digest_token, reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.time.expried.hours.ago
  end

  private

  def email_downcase
    email.downcase!
  end
end
