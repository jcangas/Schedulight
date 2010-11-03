# Scheduler Asistant

My personal project assigment for RMU

## Problem description

We want develop an  software assistant to solve a "typical class shedule problem". The description of problem domain
maybe like this:

* There are some "time slices", when studentes stay at classrom listen a professor. A simple model can be this
We denote a slice a start time, assume slices expand to next start.

    time_slices => [8, 9, 10, 11, 12]


* There area lst of avaiable professors and courses they can take

     professors = {
     [:jhon => [:math, :biology, :computers],
      :mary => [:computers, :idiom, :philosofy],
      :bob => [:history, :idiom, :philosofy],
      }

* There are some grades (or levels). A grade groups some courses with weekly work load

    grade = {
    :name => :First,
    :workload => {
        :history => 3.hours
        :math => 5.hours,
        :biology => 4.hours,
        :computers => 4.hours ,
        :idiom => 5.hours,
        :philosofy => 3.hours
    }
}

* Finally, there are, some classrooms when professors and their students meets at some time slice

classromms = {
    :A =>  :First,
    :B => :First,
}

We want to give a "problem description for a schedule" to our assistant, and request it to "solve". The asistant outputs (some time later, of course)
a shcedule arrangement for tipical week class calendar, one for each classrom. It loks like this:

               ---- Class Room :A -----

            professors:
      :jhon => :math, :biology
      :mary => :computers, :idiom
      :bob => :history, :philosofy


   Time |  Monday   | ...
-----------------------
    8   | :biology  | ...
    9   | computers | ...
     .       .          .
     .       .          .
     .       .          .


    The solution must have some restrictions, like:

    * "For a classrom and a course must have only one professor"
    * "The amount of hours for a course in a classrom, must be equal to course's workload for the classrom grade"
    * "A professor can be assigned to only a classrom for each time slice"


## Goals

  1. Develop a basic DSL to describe schedule problems. This DSL allow to write a file that the assistant can read as input.
  2. The asistant build a solution using a simple backtracing strategy (like Prolog language), checking some restrictions for reject bad solutions.
     It stop at first good solution.
  3. Use a highly modular design in order to allow future enhancements: solver-engines, ouputs formats, etc.
  4. Good rspec test set

  5. (Subgoal) support a "console mode". This can allow, in a future, adding / removing aidtional user defined restrictions in order to "refine" a solution.

