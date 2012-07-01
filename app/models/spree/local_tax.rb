class Spree::LocalTax < ActiveRecord::Base
  attr_accessible :county, :rate, :state, :zip
end
