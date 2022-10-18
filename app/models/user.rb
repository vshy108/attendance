class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, uniqueness: { case_sensitive: false }, allow_nil: false
  validates :username,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_\.]*\z/, multiline: false },
            allow_nil: false
  validates :name, presence: true
  before_save :downcase_attributes
  include DeviseTokenAuth::Concerns::User

  private

  def downcase_attributes
    attributes.select { |a| %w[username email].include? a }.each do |attr, val|
      send("#{attr}=", val.try(:downcase))
    end
  end
end
