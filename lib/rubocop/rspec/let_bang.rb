# frozen_string_literal: true

module RSpec
  # Checks `let!` calls being used for test setup.
  #
  # @example
  #   # Bad
  #   let!(:my_product) { create(:product) }
  #
  #   it 'counts products' do
  #     expect(Product.count).to eq(1)
  #   end
  #
  #   # Good
  #   let(:my_product) { create(:products) }
  #
  #   before { my_product }
  #
  #   it 'counts products' do
  #     expect(Product.count).to eq(1)
  #   end
  class LetBang < RuboCop::Cop::RSpec::Cop
    MSG = 'Do not use `let!`.'

    def_node_search :let_bang, <<-PATTERN
      (block $(send nil? :let! (sym $_)) args ...)
    PATTERN

    def on_block(node)
      return unless example_group?(node)

      let_bang(node) do |method_send, _method_name|
        add_offense(method_send, location: :expression)
      end
    end
  end
end
