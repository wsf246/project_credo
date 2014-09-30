class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessor :answers_array
  validates :question_id, presence: true
end
