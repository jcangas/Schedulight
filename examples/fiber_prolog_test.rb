#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'fiber_prolog'

FiberProlog.run do
  trace! stack: !true,
    calls: true,
    vars: !true,
    backtrack: true,
    set_var: true,
    trace: ARGV[0]

    gen_N(:N, :K).native! { |r| (1..r[:N].value).each {|n|
          r[:K] == n
          r.suspend
        }
        r.fails
    }

    gen_M(:N, :K).native! { |r| (1..r[:N].value).each {|n|
          r[:K] == n
          r.suspend
        }
        r.fails
    }

        genN_test.if genN(2, :N), writeln(:N), fails
  goal_0.if genN_test

        genNM_test.if gen_N(3, :N), gen_M(3, :M), write(:N), writeln(:M), fails
  goal_1.if genNM_test

        gensol(:A, :B).if gen_N(2,:A), gen_M(2,:B)
        gensol_test.if gensol(:X, :Y), write(:X), writeln(:Y), fails
  goal_2.if gensol_test

        collect_test.if collect(:X, genN(3, :X), :Result), writeln(:Result)
  goal_3.if collect_test

        pair_test(:P).if genN(2, :N), genN(2, :M), equ(:N, :V), equ(:M, :W), equ(:P, [:V, :W])
  goal.if pair_test(:R), writeln(:R), fails


  #member(:X, [ :X | :T])
  #member(:X, [ _ | :T]).if member(:X, :T)
end

