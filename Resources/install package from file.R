#'#############################################################################
#' Installing R packages within the data lab
#' 2021-12-16
#' 
#' By design, there is no internet access from within the data lab. As a result,
#' you can not download and install R packages from the internet.
#' Instead, Stats NZ have already pre-installed many common packages. You can 
#' view these by selecting the Packages tab in the bottom right quadrant.
#' 
#' Should you need a package that has not already been installed:
#'  - email access2microdata requesting the package
#'  - wait for notification that the package has been downloaded into the lab
#'  - confirm that you can see the package file
#'      it will most likely be in:  /nas/DataLab/GenData/R_User_Libraries
#'  - edit and run the below code
#'  
#'
#'#############################################################################

# path & package
path_package = "/nas/DataLab/GenData/R_User_Libraries/explore_0.7.1.tar.gz"

# install
install.packages(path_package, repos=NULL, type="source")
