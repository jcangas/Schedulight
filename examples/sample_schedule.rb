

# DSL sample

hours_per_day 3

subjects 'math', 'biology', 'computers', 'philosofy'

teacher('Jhon') {

  gives 'math', 'computers'

}


teacher('Mary') {

   gives 'idiom', 'philosofy'

}


teacher('Bob') {

    gives 'history'

}


grade('First') {

    workload {
        math   1
        computers 1
        philosofy 1
    }
}

classroom("A") {
    grade 'First'
}

