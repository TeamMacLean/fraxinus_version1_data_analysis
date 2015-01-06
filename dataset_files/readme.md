###### Date 2013 December 17
#### Fraxinus - ashdieback launch data - patterns 

Database dump for fraxinus game obtained from Chris Bridson  
Dump was created on 10th December 2013

A ruby script was written using active records to access the mysql database exported locally from the dump

There are 5 tables in the database

|tables
|------
|dataset
|cigar
|pattern
|user
|notificaiton


|dataset
|------
| id
| sam_file
| base_pattern
| active
| pos
| bam_filename


|cigar
|------
| id
| read_id
| row
| pos
| data
| bam_file
| dataset_id
| sequence_name
| username

|pattern
|------
|id
|user_id
|dataset_id
|score
|cigar_files
|last_saved
|current_best
|was_best
|icon_id


|user
|------
|id
|name
|fbid
|score
|bonus_points
  
|notification
|------
|id
|type
|timestamp
|player_from
|player_to
|fb_request_id
|dataset_id
|new_score
|prev_score

produced sam entries and dataset pattern entries using following command

`ruby mysql2files_dataset_saminfo.rb > bamfilename_pattern_count.txt`  

