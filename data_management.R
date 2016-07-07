library("micropem")

####################################################
# DATA CHAI
####################################################
micropemChai <- convert_output(system.file("extdata", "CHAI.csv",
                                               package = "micropem"))
save(micropemChai, file = "data/micropemChai.RData", compress='xz')


####################################################
# DATA COLUMBIA 1
####################################################
micropemC1 <- convert_output(system.file("extdata",
                                             "Columbia.csv",
                                             package = "micropem"))
save(micropemC1, file = "data/micropemC1.RData", compress='xz')



####################################################
# DATA COLUMBIA 2
####################################################
micropemC2 <- convert_output(system.file("extdata",
                                             "Columbia2.csv",
                                             package = "micropem"))
save(micropemC2, file = "data/micropemC2.RData", compress='xz')
