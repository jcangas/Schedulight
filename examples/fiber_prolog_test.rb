#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'fiber_prolog'

FiberProlog.run do
  trace! stack: !true,
    calls: true,
    binds: !true,
    vars: !true,
    backtrack: true,
    set_var: true,
    trace: ARGV[0]

    gen_N(:N, :KN).native! { |r| (1..r[:N].value).each {|n|
          r[:KN].unify n
          r.suspend
        }
        r.fails
    }

    gen_M(:N, :KM).native! { |r| (1..r[:N].value).each {|n|
          r[:KM].unify n
          r.suspend
        }
        r.fails
    }



        genN_test.if genN(2, :X), writeln(:X), fails

        genNM_test.if gen_N(2, :N), gen_M(2, :M), write(:N), writeln(:M), fails

        gensol(:A, :B).if gen_N(2,:A), gen_M(2,:B)
        gensol_test.if gensol(:X, :Y), write(:X), writeln(:Y), fails

        collect_test.if collect(:X, genN(3, :X), :Result), writeln(:Result)

        pair_test.if gen_N(2, :N), gen_M(2, :M), equ(:N, :M), write(:N), write(:M), newln, fails

        list_test.if gen_N(2, :N), gen_M(2, :M), equ(:L, [:N, :M]), writeln(:L), fails


  {
      :genN_test => "Test simple rule reeval",
      :genNM_test  => "Test multiple rule reeval",
      :gensol_test => "Test multiple reeval in nested rule",
      :collect_test => "Test collect multiples results",
      :pair_test => "Test var unification",
      :list_test => "Test list unification"

  }.each do |test, desc|
    goal.body[0] = self.send test
    puts desc
    goal.new.call
  end

  goal.if cut #list_test

  #member(:X, [ :X | :T])
  #member(:X, [ _ | :T]).if member(:X, :T)
end

