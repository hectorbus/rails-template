# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  role_id                :integer
#  first_name             :string
#  last_name              :string
#  maiden_name            :string
#  username               :string
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#

class User < ActiveRecord::Base
  # Include defaults devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  attr_accessor :current_password

  has_attached_file :avatar, styles: {thumb: '400x400#', medium: '150x150#', small: '60x60#'},
                    default_url: ->(attachment) { ActionController::Base.helpers.asset_path('user_image.png') }
  validates_attachment_content_type :avatar, content_type: %w(image/jpeg image/jpg image/png image/gif)
  validates_attachment_size :avatar, less_than: 5.megabytes

  belongs_to :role
  before_create :set_default_role
  delegate :name, to: :role, prefix: true

=begin
  validates_presence_of :role_id, :email, :first_name, :last_name, :maiden_name, :username
  validates :username, length: {minimum: 4, maximum: 25},
            format: {with: /(^[a-z0-9_\.]+$)/}
  validates :first_name, :last_name, :maiden_name, format: {with: /(^[a-zA-Z\sáéíóúü]+$)/}
=end

  before_destroy :last_user_god?

  def god?
    role and role.key == 'god'
  end

  def full_name
    "#{self.first_name} #{self.last_name} #{self.maiden_name}"
  end

  def first_name=(s)
    super s.titleize
  end

  def last_name=(s)
    super s.titleize
  end

  def maiden_name=(s)
    super s.titleize
  end

  private
  def set_default_role
    self.role ||= Role.find_by_key('default')
  end

  def last_user_god?
    if self.role.key == 'god' and User.where(role_id: Role.find_by(key: 'god').id).count == 1
      errors.add(:base, I18n.t('devise.registrations.one_user_god'))
      false
    end
  end
end
