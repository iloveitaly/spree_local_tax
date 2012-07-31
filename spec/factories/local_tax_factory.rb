FactoryGirl.define do
  factory :local_tax, :class => Spree::LocalTax do
    local 0.05
    other 0.005
    city 'Test'
    state  { |address| address.association(:state) }
  end

  factory :tax_category_with_local_tax, :parent => :tax_category do
    after_create do |tax_category|
      tax_category.tax_rates.build(:amount => 0.05, :calculator => Spree::Calculator::LocalTax.new) do |r|
        r.zone = Spree::Zone.find_by_name('GlobalZone') || FactoryGirl.create(:global_zone)
      end.save!
    end
  end
end