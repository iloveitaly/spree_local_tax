FactoryGirl.define do
  factory :local_tax, :class => Spree::LocalTax do
    local 0.05
    other 0.005
    city 'Test'
    state  { |address| address.association(:state) }
  end

  # https://github.com/spree/spree/blob/1-3-stable/core/lib/spree/core/testing_support/factories/tax_category_factory.rb
  factory :tax_category_with_local_tax, :parent => :tax_category do
    after_create do |tax_category|
      tax_category.tax_rates.create!({
        :amount => 0.05,
        :calculator => Spree::Calculator::LocalTax.new,
        :zone => Spree::Zone.find_by_name('GlobalZone') || FactoryGirl.create(:global_zone)
      }, without_protection: true)
    end
  end
end