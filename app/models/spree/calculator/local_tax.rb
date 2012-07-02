require_dependency 'spree/calculator'

module Spree
  class Calculator::LocalTax < Calculator::DefaultTax
    def self.description
      I18n.t(:local_tax)
    end

    private

      def compute_order(order)
        # calculate the tax rate based on order billing location
        # the rate will be calculated:
        #     1) by querying the spree_local_taxes DB for a county + state match
        #     1) by querying the spree_local_taxes DB for a zip match
        #     2) by falling back to the rate.amount

        # TODO the idea here is to provide multiple backends to use to calculate taxes
        # the first (and easiest + most reliable for my use case) is SQL / CSV data
        # other options
        #   http://developer.avalara.com/
        #   https://taxcloud.net/default.aspx

        # assumes SQL backend for now

        local_tax = Spree::LocalTax.find_by_county_and_state_id(order.bill_address.city.upcase, order.bill_address.state.id)
        local_tax = Spree::LocalTax.find_by_zip(order.bill_address.zipcode) if local_tax.blank?
        tax_rate = local_tax.present? ? local_tax.rate : rate.amount

        # TODO there should be preferences to choose to include shipping, promotions, etc in the tax calculation
        possible_adjustments = order.adjustments.eligible
        adjustment_totals = (possible_adjustments.shipping + possible_adjustments.promotion).map(&:amount).sum

        line_items_total = order.line_items.select do |line_item|
          line_item.product.tax_category == rate.tax_category
        end.sum(&:total)

        # TODO the only issue here is that the label text for the adjustment is not calculated
        # based on the rate method here, the TaxRate.amount is used instead
        # need to modify https://github.com/spree/spree/blob/master/core/app/models/spree/tax_rate.rb#L47

        round_to_two_places((line_items_total + adjustment_totals) * tax_rate)
      end

  end
end