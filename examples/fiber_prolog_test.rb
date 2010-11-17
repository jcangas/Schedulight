#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'fiber_prolog'

FiberProlog.run do
  trace! stack: !true,
    calls: true,
    vars: !true,
    backtrack: true,
    set_var: !true,
    trace: ARGV[0]

  genN(:N, :K).native! { |r| (1..r[:N].value).each {|n|
        r[:K] == n
        r.suspend
      }
      r.fails
  }

  gensol(:A, :B, :C).if genN(2,:A), genN(2,:B), genN(2,:C)

  genN_test.if genN(3, :N), writeln(:N), fails

  genNM_test.if genN(3, :N), genN(3, :M), write(:N), writeln(:M), fails

  gensol_test.if gensol(:X, :Y, :Z), write(:X), write(:Y), writeln(:Z), fails

  collect_test.if collect(:X, genN(3, :X), :Result), writeln(:Result)

  # goal.if genN_test
  # goal.if genNM_test
   goal.if gensol_test
  # goal.if collect_test

  #member(:X, [ :X | :T])
  #member(:X, [ _ | :T]).if member(:X, :T)
end

