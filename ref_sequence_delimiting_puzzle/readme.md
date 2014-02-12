###### Date 2013 December 17
#### Fraxinus - ashdieback launch data - patterns 

select_vcf_from_dataset_patterns.rb script was used to extract vcf info from the database pattern output (../dataset_files) in combination with tab files used to add to the game

resulting files were created as vcf format without sequence information at the begining

`select_vcf_from_dataset_patterns.rb ../dataset_files/Dataset_entris-*** ***.tab > ***.vcf`



`uby pattern_longref_to_selected_vcf.rb --fasta Chalara_fraxinea_TGAC_s1v1_contigs.fa --vcf ../vcf_files_and_selected_list/ashwellthorpe_AT1_vs_tgac1_selected.vcf > ashwellthorpe_AT1_vs_tgac1_selected_200bp_ref.vcf`
