###### Date 2013 December 17
#### Fraxinus - ashdieback launch data - patterns 

select_vcf_from_dataset_patterns.rb script was used to extract vcf info from the database pattern output (../dataset_files) in combination with tab files used to add to the game

resulting files were created as vcf format without sequence information at the begining

`select_vcf_from_dataset_patterns.rb ../dataset_files/Dataset_entris-*** ***.tab > ***.vcf`


command line example:  
`vcf_files_and_selected_list rallapag$ ruby select_vcf_from_dataset_patterns.rb ../dataset_files/Dataset_entries-ashwellthorpe1_vs_tgac1-pe.sorted.bam.txt ashwellthorpe_AT1_vs_tgac1_AT_LEAST_ONE_ALT.tab > ashwellthorpe_AT1_vs_tgac1_selected.vcf`
