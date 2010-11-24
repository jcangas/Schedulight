# Scheduler Asistant

My personal project assigment for RMU

## Problem description

We want develop an  software assistant to solve a "typical class shedule problem". The description of problem domain maybe like this:

* There are some "time slices", when studentes stay at classrom listen a professor. A simple model can be this
We denote a slice with a mark start time, assume slices expand to next start.

        Time Marks:  8, 9, 10, 11, 12


* There area list of avaiable professors and subjects they can take

 Professors | Subjects
 -----------|------------
      Jhon  | Math, Biology, Computers
      Mary  | Computers, Idiom, Philosofy
      Bob   | History, Idiom, Philosofy

* There are some grades (or levels). A grade groups some courses with weekly work load


    Grade "First"

Subject   | Workload
---------------|--------------
History   | 3 hours
Math      | 5 hours
Biology   | 4 hours
Computers | 4 hours
Idiom     | 5 hours
Philosofy | 3 hours

* Finally, there are, some classrooms when professors and their students meets at some time slice

Class Room | Grade
------------|--------
    "A"    | "First"
    "B"    | "Second"

We want to give a "problem description for a schedule" to our assistant, and request it to "solve". The asistant outputs (some time later, of course)
a shcedule arrangement for tipical week class calendar, one for each classrom. It loks like this:

    Class Room "A"

Professors  |  Subjects
------------|---------------
      Jhon  | Math, Biology
      Mary  | Computers, Idiom
      Bob   | History, Philosofy


  Time  |  Monday   | ...
--------|-----------|-----
    8   | Biology   | ...
    9   | Computers | ...
     .  |     .     |   .
     .  |     .     |   .
     .  |     .     |   .


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

