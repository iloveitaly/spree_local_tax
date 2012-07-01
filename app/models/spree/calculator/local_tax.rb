require_dependency 'spree/calculator'

module Spree
  class Calculator::LocalTax < Calculator::DefaultTax
    def self.description
      I18n.t(:local_tax)
    end

    private

      def compute_order(order)
        matched_line_items = order.line_items.select do |line_item|
          line_item.product.tax_category == rate.tax_category
        end

        # calculate the tax rate based on order billing location
        # the rate will be calculated:
        #     1) by querying the spree_local_taxes DB for a county match
        #     2) by querying the spree_local_taxes DB for a zip match
        #     3) by falling back to the rate.amount

        # TODO the idea here is to provide multiple backends to use to calculate taxes
        # the first (and easiest + most reliable for my use case) is SQL / CSV data
        # other options
        #   http://developer.avalara.com/
        #   https://taxcloud.net/default.aspx

        # assumes SQL backend

        # Spree::LocalTax.find_by_zip order.bill_address.zipcode

        line_items_total = matched_line_items.sum(&:total)
        adjusted_total = (adjustments.eligible - adjustments.tax - adjustments.shipping).sum(&:amount)
        round_to_two_places((line_items_total + adjusted_total) * rate.amount)
      end

      def compute_line_item(line_item)
        if line_item.product.tax_category == rate.tax_category
          deduced_total_by_rate(line_item.total, rate)
        else
          0
        end
      end

  end
end