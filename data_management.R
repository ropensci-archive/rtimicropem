library("ammon")

####################################################
# DATA CHAI
####################################################
dummyMicroPEMChai <- convertOutput(system.file("extdata", "dummyCHAI.csv",
                                               package = "ammon"),
                                   version="CHAI")
save(dummyMicroPEMChai, file = "data/dummyMicroPEMChai.RData", compress='xz')


####################################################
# DATA COLUMBIA 1
####################################################
dummyMicroPEMC1 <- convertOutput(system.file("extdata",
                                             "dummyColumbia.csv",
                                             package = "ammon"),
                                 version="Columbia1")
save(dummyMicroPEMC1, file = "data/dummyMicroPEMC1.RData", compress='xz')



####################################################
# DATA COLUMBIA 2
####################################################
dummyMicroPEMC2 <- convertOutput(system.file("extdata",
                                             "dummyColumbia2.csv",
                                             package = "ammon"),
                                 version="Columbia2")
save(dummyMicroPEMC2, file = "data/dummyMicroPEMC2.RData", compress='xz')
