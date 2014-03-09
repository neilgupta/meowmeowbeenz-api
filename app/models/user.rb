require 'bcrypt'
require 'securerandom'

class User < ActiveRecord::Base
  include BCrypt

  has_attached_file :photo
  has_many :meows_given, class_name: "Rating",
                         foreign_key: "reviewer_id",
                         inverse_of: :reviewer
  has_many :meows_received, class_name: "Rating",
                            foreign_key: "reviewee_id",
                            inverse_of: :reviewee

  has_and_belongs_to_many :ratings

  validates :username, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true

  # case-insensitive find_by_username
  def self.find_by_username(name)
    User.where("LOWER(username) = ?", name.downcase).first
  end

  def password
    password_hash = read_attribute(:password)
    return nil unless password_hash
    @password ||= Password.new(password_hash)
  end

  def password=(new_pass)
    if new_pass.blank?
      @password = nil
      write_attribute(:password, nil)
    else
      @password = Password.create(new_pass)
      write_attribute(:password, @password)
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

  def beenz_received_from_user(user)
    meows_received.where(reviewer: user).try(:first).try(:beenz)
  end

  def beenz_given_to_user(user)
    meows_given.where(reviewee: user).try(:first).try(:beenz)
  end

  def give_beenz_to_user(beenz, user)
    rating = meows_given.where(reviewee: user).try(:first) || meows_given.build(reviewee: user)
    rating.beenz = beenz
    rating.save!
  end

  def beenz
    b = ActiveRecord::Base.connection.execute("
      select SUM(beenz * weight)/SUM(weight) as score FROM ratings WHERE reviewee_id = #{id}
    ")[0]['score'].to_f

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
