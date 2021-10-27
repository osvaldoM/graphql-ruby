# frozen_string_literal: true
module GraphQL
  module StaticValidation
    module UniqueDirectivesPerLocation
      DIRECTIVE_NODE_HOOKS = [
        :on_fragment_definition,
        :on_fragment_spread,
        :on_inline_fragment,
        :on_operation_definition,
        :on_scalar_type_definition,
        :on_object_type_definition,
        :on_input_value_definition,
        :on_field_definition,
        :on_interface_type_definition,
        :on_union_type_definition,
        :on_enum_type_definition,
        :on_enum_value_definition,
        :on_input_object_type_definition,
        :on_field,
      ]

      DIRECTIVE_NODE_HOOKS.each do |method_name|
        define_method(method_name) do |node, parent|
          if node.directives.any?
            validate_directive_location(node)
          end
          super(node, parent)
        end
      end

      private

      def validate_directive_location(node)
        used_directives = {}
        node.directives.each do |ast_directive|
          break if @context.too_many_errors?
          directive_name = ast_directive.name
          if used_directives[directive_name]
            add_error(GraphQL::StaticValidation::UniqueDirectivesPerLocationError.new(
              "The directive \"#{directive_name}\" can only be used once at this location.",
              nodes: [used_directives[directive_name], ast_directive],
              directive: directive_name,
            ))
          else
            used_directives[directive_name] = ast_directive
          end
        end
      end
    end
  end
end
