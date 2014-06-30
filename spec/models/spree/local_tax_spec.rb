require 'spec_helper'

describe Spree::LocalTax do
  before do
    # this has to be done first so the @order items are created with proper default associations
    tax_category = FactoryGirl.create(:tax_category_with_local_tax, :is_default => true)
    tax_category.is_default = true
    tax_category.save!

    @tax_calculator = tax_category.tax_rates.first.calculator
    @address = FactoryGirl.create :address

    # the totals are not automatically calculated
    # for line items to be picked up you have to reload
    @order = FactoryGirl.create :order_with_totals, :bill_address => @address, :ship_address => @address
    @order.reload
    @order.update!
    @order.save!
  end

  let(:order) { @order }
  let(:address) { @address }
  let(:tax_calculator) { @tax_calculator }

  context "sql backend" do
    it "should change local tax amount based on zip code" do
      # 0.05 is default tax rate
      tax_amount = tax_calculator.compute(order)
      order.item_total.to_f.should_not == 0.0
      tax_amount.should == order.item_total * 0.05

      # without zip
      local_tax = FactoryGirl.create :local_tax, :state => order.bill_address.state
      tax_calculator.compute(order).to_f.should == tax_amount.to_f

      # with zip
      local_tax.update_column :zip, order.bill_address.zipcode
      tax_calculator.compute(order).to_f.should_not == tax_amount.to_f
    end

    it "should change local tax amount based on city + state" do
      
    end

    it "should fallback to the default tax amount when no local tax exists" do

    end

    it "should calculate the taxable amount as item total - promotions + shipping" do
      calculator = tax_calculator

      # without promotion or shipping
      calculator.taxable_amount(order).should == order.item_total.to_f

      # without promotion
      order.shipping_method = FactoryGirl.create :shipping_method
      order.create_shipment!
      order.adjustments.shipping.count.should == 1
      order.item_total.to_f.should_not == 0.0
      calculator.taxable_amount(order).to_f.should == (order.item_total + order.ship_total).to_f

      # with everything
      order.adjustments.create!({ :label => "A Promo", :originator_type => 'Spree::PromotionAction', :amount => 20.0 }, without_protection: true)
      order.adjustments.promotion.count.should == 1
      amt = order.item_total + order.ship_total + 20.0
      calculator.taxable_amount(order).should == amt

      # with other adjustment (not-promotion)
      order.adjustments.create!({ :label => 'another adjustment', :amount => 10.0 })
      order.adjustments.count.should == 3 # shipping + promotion + other
      calculator.taxable_amount(order).should == amt
    end
  end

  context "tax cloud backend" do
    
  end
end
