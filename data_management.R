library("ammon")

####################################################
# DATA CHAI
####################################################
dummyMicroPEMChai <- convert_output(system.file("extdata", "dummyCHAI.csv",
                                               package = "ammon"))
save(dummyMicroPEMChai, file = "data/dummyMicroPEMChai.RData", compress='xz')


####################################################
# DATA COLUMBIA 1
####################################################
dummyMicroPEMC1 <- convert_output(system.file("extdata",
                                             "dummyColumbia.csv",
                                             package = "ammon"))
save(dummyMicroPEMC1, file = "data/dummyMicroPEMC1.RData", compress='xz')



####################################################
# DATA COLUMBIA 2
####################################################
dummyMicroPEMC2 <- convert_output(system.file("extdata",
                                             "dummyColumbia2.csv",
                                             package = "ammon"))
save(dummyMicroPEMC2, file = "data/dummyMicroPEMC2.RData", compress='xz')
