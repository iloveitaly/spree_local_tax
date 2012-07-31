class Spree::LocalTax < ActiveRecord::Base
  attr_accessible :county, :local, :other, :zip
  belongs_to :state, :class_name => "Spree::State"

  def rate
    state.tax + local + other
  end
end
