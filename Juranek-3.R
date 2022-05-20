# Daphne Virlar-Knight; May 19 2022
# Publishing data with DOI



## -- load libraries -- ##
library(dataone)
library(datapack)
library(uuid)
library(arcticdatautils)
library(EML)



## -- general setup -- ##
# run token in console
# get nodes
d1c <- D1Client("PROD", "urn:node:ARCTIC")

# Get the package
packageId <- "resource_map_urn:uuid:eb638072-4c76-4858-b48d-35d62c4bd0b0"
dp <- getDataPackage(d1c, identifier = packageId, lazyLoad=TRUE, quiet=FALSE)


# Get the metadata id
xml <- selectMember(dp, name = "sysmeta@fileName", value = ".xml")


# Read in the metadata
doc <- read_eml(getObject(d1c@mn, xml))



## -- publish update -- ##

# write eml
eml_path <- "~/Scratch/Surface_Dissolved_Oxygen_and_Oxygen_Argon.xml"

write_eml(doc, eml_path)

# assign pre-issued DOI to doi object
doi <- dataone::generateIdentifier(d1c@mn, "DOI")


dp <- replaceMember(dp, xml, replacement = eml_path, newId = doi)



## -- upload package -- ##
# Set access rules
myAccessRules <- data.frame(subject="CN=arctic-data-admins,DC=dataone,DC=org", 
                            permission="changePermission") 

newPackageId <- uploadDataPackage(d1c, dp, public=TRUE, quiet=FALSE,
                                  AccessRules = myAccessRules)



# Manually set ORCiD
subject <- 'http://orcid.org/0000-0002-4922-8263'


# Get data pids
ids <- getIdentifiers(dp)

# set rights
set_rights_and_access(d1c@mn,
                      pids = c(ids, packageId),
                      subject = subject,
                      permissions = c('read', 'write', 'changePermission'))
