class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username,
            :presence => true,
            :uniqueness => {
            :case_sensitive => false
          }

  validate :validate_username

  has_many :attended_events, :through => :attendees, :source => :event
  has_many :organized_events, :through => :organizers, :source => :event
  has_many :organizers
  has_many :attendees



  attr_accessor :login

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end

  def admin?
    self.admin == true
  end

end
