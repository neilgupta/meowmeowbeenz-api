require 'bcrypt'
require 'securerandom'

class User < ActiveRecord::Base
  default_scope where(deleted: false)
  
  has_attached_file :photo
  has_many :meows_given
  has_many :meows_received

  has_and_belongs_to_many :ratings

  validates :username, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true

  # case-insensitive find_by_username
  def self.find_by_username(name)
    User.where("LOWER(username) = ?", name.downcase).first
  end

  def password
    return nil unless password_hash
    @password ||= Password.new(password_hash)
  end

  def password=(new_pass)
    if new_pass.blank?
      @password = nil
      self.password_hash = nil
    else
      @password = Password.create(new_pass)
      self.password_hash = @password
    end
  end

  def token
    read_attribute(:token) || generate_token
  end

  def generate_token
    write_attribute(:token, "#{id}#{SecureRandom.hex}")
  end

  def photo_url
    photo.try(:url)
  end

  def beenz_given_by_user(user)
    meows_received.where(reviewer: user).try(:beenz)
  end

  def beenz
    b = meows_received.select("SUM(score * weight)/SUM(weight)")
    # b = ActiveRecord::Base.connection.execute("select SUM(score * weight)/SUM(weight) FROM ratings WHERE reviewee_id = #{id}")
    return case
    when b > 4.75 then 5
    when b > 4.25 then 4.5
    when b > 3.75 then 4
    when b > 3.25 then 3.5
    when b > 2.75 then 3
    when b > 2.25 then 3.5
    when b > 1.75 then 2
    when b > 1.25 then 1.5
    else
      1
    end
  end
end
