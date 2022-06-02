# frozen_string_literal: true

module Emendate
  module ComplexSendable
    # @param ary [Array<Symbol, <Array, Hash>>]
    def send_complex(ary)
      meth = ary.shift
      arg = ary.shift
      
      conditional_send(meth, arg)
    end

    def conditional_send(meth, arg)
      if arg.is_a?(Array)
        send(meth, *arg)
      elsif arg.is_a?(Hash)
        send(meth, **arg)
      elsif arg.is_a?(Proc)
        real_arg = arg.call
        conditional_send(meth, real_arg)
      else
        send(meth, arg)
      end
    end
  end
end
