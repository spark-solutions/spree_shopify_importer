Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name:         'adds_tag_list_to_admin_product',
  insert_after: '[data-hook="admin_product_form_tag_list"]',
  text:         <<-HTML
                  <div data-hook="admin_product_form_tag_list">
                    <%= f.field_container :tag_list, class: ['form-group'] do %>
                      <%= f.label :tag_list, Spree.t(:tags) %>
                      <%= f.hidden_field :tag_list, value: @product.tag_list.join(','), class: 'tag_picker' %>
                    <% end %>
                  </div>
                HTML
)