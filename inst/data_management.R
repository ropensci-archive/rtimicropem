dummyMicroPEMChai <- convertOutput(system.file("extdata", "dummyCHAI.csv", package = "ammon"),
                 version="CHAI")
save(dummyMicroPEMChai, file = paste0(getwd(), "/data/",
                                      "dummyMicroPEMChai.RData"), compress='xz')
