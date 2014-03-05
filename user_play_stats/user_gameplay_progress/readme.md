###### Date 2013 December 17
#### Fraxinus - ashdieback launch data - user stats extraction 

notification table has type as column name and has been changed to relations, to avoid errors from active record

`ruby connect_mysql_db.rb`  
-- rename_column(:notification, :type, :relations)  
   -> 0.0324s

then a script written to extract username, timestamp of each game play and the score improvements for each game play  
`ruby user_timeline_details.rb > user_timeline_data_out.txt`