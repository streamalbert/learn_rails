class Micropost < ActiveRecord::Base
  belongs_to :user
  # “stabby lambda” syntax for an object called a Proc (procedure) or lambda, 
  # which is an anonymous function (a function created without a name). 
  # The stabby lambda -> takes in a block and returns a Proc, which can then be evaluated with the "call" method.
  # Rails supports default ordering via default_scope.
  default_scope -> { order(created_at: :desc) }
  # The way to tell CarrierWave to associate the image with a model is to use the mount_uploader method, 
  # which takes as arguments a symbol representing the attribute and the class name of the generated uploader
  # PictureUploader is defined in the file picture_uploader.rb
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size

  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
