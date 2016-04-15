# Run these commands for a closed OTU picking 
# Followed by adding the meta data into the file 

echo "pick_otus:enable_rev_strand_match True"  >> $PWD/otu_picking_params_97.txt
echo "pick_otus:similarity 0.97" >> $PWD/otu_picking_params_97.txt

workon QiimeVenv
pick_closed_reference_otus.py -i $PWD/seqs.fna -o $PWD/ucrC97/ -p $PWD/otu_picking_params_97.txt -r $PWD/gg_13_5_otus/rep_set/97_otus.fasta -a -O 20
deactivate

# Add metadata to the biom file to port it to Phinch
biom add-metadata -i otu_table_mc2_w_tax.biom -o otu_table_mc2_w_tax_and_metadata.biom -m sample_metadata_mapping_file.txt

# To Picrust Script


