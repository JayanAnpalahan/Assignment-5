# The package "rentrez" is R's way of pulling data using Entrez. 
# Entrez is basically a connection between the databases provided by NCBI, and the user in R. 
# In other words, you can pull stuff from the databases, using R.

# Using "library" and calling upon "rentrez" to be active for this project
library("rentrez")


# Setting "ncbi_ids" to a concatenated set of strings, which correspond to accession numbers.
# Accession numbers are basically IDs for DNA sequences or Proteins (Amino Acid sequences)

ncbi_ids = c("HQ433692.1","HQ433694.1","HQ433691.1")


# "entrez_fetch" is a function where you can pull data from a specified database, using specified IDs, and
# a specified format

# Here, "Bburg" which stands for "Borrelia burgdorferi" (bacteria), is set to the fetched data from the database

# entrez_fetch will use the following commands:

# "db" = the database to fetch from. In this case, "nuccore"

# "id" = the specified IDs we would like from this database. In this case, we already specified the IDs of interest
# as "ncbi_ids"

# "rettype" is the format in which we want the data to be in. In this case, "fasta" which is text-format that can be
# amino acids (if protein) or nucleotides (If DNA, or RNA)

Bburg = entrez_fetch(db = "nuccore", id = ncbi_ids, rettype = "fasta")

# Since FASTA format usually has a ">" (greater than) symbol before the header (sequence ID and type), 
# if you use "soulsplit", you can "split" at the ">" mark, and be left with the header and sequence.

SequenceswHeader = strsplit(Bburg, split = ">")

# We don't want that though, we want just the nucleotides. 
# First, a "gsub" is used to find every instance of the word "sequence", and then replace it with itself (i.e no change)
# with a "<" symbol.
# This just adds better visualization for the range of values we need to remove.

SequenceFilter1 = gsub("(sequence)+", "\\1<", Bburg)

# Next, we remove those values!
# This is done by using "gsub" to find ">" and "<" symbols, and
# inbetween we want "[^>]" which is basically the negation of the ">" symbol. 
# What this does, is finds the ">" symbol first, then checks for every character that is not ">" (via negation),
# and finally "<". All of this is replaced by a ">".
# Why keep a ">"? This will become clear later.
SequenceFilter2 = gsub(">[^>]+<", ">", SequenceFilter1)

# Next, we still have some values that are not nucleotide values, so we need to remove them.
# This filter removes every single value that is not negated ("[^]").
# The negated values are ACTG (our nucleotides) and the ">" symbol.
# Why not just use this filter at the very beginning? 
# This is because any capital A, C, T, G in the header will also be preserved!
# SO we needed to filter out the header individually first.
SequenceFilter3 = gsub("[^A|C|T|G|>]+", "", SequenceFilter2)

# Now we are left with JUST the nucleotides and the ">" at the beginning of each nucleotide sequence.
# The next step is to split this character vector suing "strsplit", and we can split it at the ">"!
SequencesOnly = strsplit(SequenceFilter3, split = ">")

# These sequences in the form of a list are then "written into" (basically saved as) a csv called "Sequences".
write.csv(SequencesOnly,"Sequences.csv")