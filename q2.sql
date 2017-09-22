--q2a
ALTER TABLE inproceedings
Add column Area text;

--q2b
--database
update inproceedings
set Area = 'Database'
where booktitle = 'SIGMOD Conference' or booktitle = 'VLDB' or booktitle = 'ICDE' or booktitle = 'PODS'; 

--Theory
update inproceedings
set Area = 'Theory'
where booktitle = 'STOC' or booktitle = 'SODA' or booktitle = 'ICALP' or booktitle = 'FOCS'; 

--Systems
update inproceedings
set Area = 'Systems'
where booktitle = 'SIGCOMM' or booktitle = 'ISCA' or booktitle = 'HPCA' or booktitle = 'PLDI'; 

--ML-AI
update inproceedings
set Area = 'ML-AI'
where booktitle = 'ICML' or booktitle = 'NIPS' or booktitle = 'AAAI' or booktitle = 'IJCAI'; 

--Set other to UNKOWN
update inproceedings
set AREA = 'UNKNOWN'
where Area is NULL;
